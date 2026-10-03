{
  callPackage,
  cacert,
  claude-code,
  codex,
  fetchFromGitHub,
  git,
  lib,
  makeWrapper,
  node-gyp,
  nodejs_24,
  opencode,
  pnpm_11,
  python3,
  stdenv,
  writableTmpDirAsHomeHook,
}:

let
  version = "0.0.45";

  src = fetchFromGitHub {
    owner = "pingdotgg";
    repo = "t3code";
    tag = "v${version}";
    hash = "sha256-8drTHjFqa2vJ96jhpRZXmNbtbXtKk1q40jOEp9dohNc=";
  };

  # Server-only slice of the workspace: the t3 server, the web client it
  # serves, and the monorepo root for the vp build runner. Desktop and mobile
  # workspaces (Electron, Expo) are excluded.
  installFlags = [
    # `scripts` provides tooling the t3 build scripts import directly.
    "--filter=t3..."
    "--filter=@t3tools/web..."
    "--filter=@t3tools/scripts..."
    "--filter=@t3tools/monorepo"
    "--frozen-lockfile"
    # The workspace's allowed install scripts only validate shipped artifacts
    # (esbuild, node-pty prebuilds); node-pty is rebuilt from source later.
    # The root `prepare` hook needs tools that assume an interactive checkout.
    "--ignore-scripts"
    # The upstream package.json pins pnpm@11.10.0 via the packageManager field;
    # without this pnpm tries to download its own pinned copy at run time.
    "--config.manage-package-manager-versions=false"
  ];

  nodeModules = stdenv.mkDerivation {
    pname = "t3code-node-modules";
    inherit version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      # The nix sandbox clears SSL_CERT_FILE; without a CA bundle Node's
      # registry fetches fail TLS verification.
      cacert
      nodejs_24
      pnpm_11
      writableTmpDirAsHomeHook
    ];

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      # Deterministic store/cache paths so absolute paths recorded in
      # node_modules/.modules.yaml do not change the fixed-output hash.
      npm_config_store_dir = "/build/.pnpm-store";
      npm_config_cache_dir = "/build/.pnpm-cache";
    };

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      pnpm install ${lib.escapeShellArgs installFlags}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # Filtered installs give each in-scope workspace project its own
      # node_modules next to the root one; preserve the whole layout so the
      # relative symlinks into the root .pnpm store keep resolving.
      mkdir -p $out
      find . -maxdepth 3 -type d -name node_modules | while read -r modules; do
        mkdir -p "$out/$(dirname "$modules")"
        cp -R "$modules" "$out/$modules"
      done

      # pnpm's bookkeeping files embed build-time timestamps; they are not
      # needed to build or run, and would make the output hash unstable.
      find $out \( -name .modules.yaml -o -name .pnpm-workspace-state-v1.json \) -delete

      # pnpm's cmd-shims embed the absolute build directory, which nix
      # randomizes per build. Rewrite it to a fixed path: the shims resolve
      # their target relative to $basedir, so the placeholder never has to
      # exist and NODE_PATH entries pointing at it are ignored by Node.
      find $out -type d -name .bin | while read -r bindir; do
        find "$bindir" -type f -exec sed -i "s|$PWD|/build/source|g" {} +
      done

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-HN5WfjAZKKjvQgBycFMsxbEWj2ts/1xTy3x4SZlmHE0=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "t3code";
  inherit version src;

  nativeBuildInputs = [
    cacert
    git
    makeWrapper
    node-gyp
    nodejs_24
    pnpm_11
    python3
    writableTmpDirAsHomeHook
  ];

  env = {
    # Any pnpm call vp may spawn must not try to self-switch to the pinned
    # version or "repair" the filtered node_modules tree.
    npm_config_manage_package_manager_versions = "false";
    npm_config_verify_deps_before_run = "false";
  };

  configurePhase = ''
    runHook preConfigure

    cp -R ${nodeModules}/node_modules .
    # Restore the per-project node_modules of every workspace package the
    # filtered install created.
    for modules in \
      ${nodeModules}/apps/*/node_modules \
      ${nodeModules}/packages/*/node_modules \
      ${nodeModules}/infra/*/node_modules \
      ${nodeModules}/scripts/node_modules \
      ${nodeModules}/oxlint-plugin-t3code/node_modules; do
      if [ -e "$modules" ]; then
        target="''${modules#${nodeModules}/}"
        mkdir -p "$(dirname "$target")"
        cp -R "$modules" "$target"
      fi
    done
    chmod -R u+w node_modules apps packages infra scripts oxlint-plugin-t3code 2>/dev/null || true
    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # Run vp directly: `pnpm exec` would first run its deps-status check and
    # abort because node_modules is a filtered subset of the lockfile.

    # Builds @t3tools/web first (declared via run.tasks dependsOn), then the
    # t3 server bundle, and copies the web client into dist/client.
    ./node_modules/.bin/vp run --filter t3 build

    # Replace node-pty's shipped prebuilds with a build linked against the
    # nixpkgs Node headers and libstdc++, so dlopen succeeds on NixOS.
    # pnpm does not hoist: the package lives under apps/server/node_modules.
    # node-gyp rejects symlinked --directory paths, so resolve the real
    # package directory inside the pnpm store first.
    rm -rf apps/server/node_modules/node-pty/prebuilds
    ptyDir=$(readlink -f apps/server/node_modules/node-pty)
    node ${node-gyp}/lib/node_modules/node-gyp/bin/node-gyp.js rebuild \
      --directory="$ptyDir" \
      --nodedir=${nodejs_24} \
      --build-from-source \
      --jobs="''${NIX_BUILD_CORES:-1}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Keep the monorepo layout: pnpm's node_modules symlinks are relative to
    # the workspace root, so the server package must stay at
    # apps/server for them to resolve, with the root node_modules beside it.
    mkdir -p $out/lib/t3code/apps/server $out/bin
    cp -R node_modules $out/lib/t3code/node_modules
    cp -R apps/server/node_modules $out/lib/t3code/apps/server/node_modules
    cp -R apps/server/dist $out/lib/t3code/apps/server/dist
    # The CLI reads its version from the adjacent package.json.
    cp apps/server/package.json $out/lib/t3code/apps/server/package.json

    # The build needs the full node_modules tree; everything below only
    # prunes the installed copy in $out.

    # Sourcemaps are not served and never read at run time: strip them
    # everywhere (web client, server chunks and node_modules debug maps).
    find $out/lib/t3code -name '*.map' -type f -delete

    # pnpm's cmd-shims in .bin directories are build-time only and embed
    # placeholder paths; nothing resolves through them at run time.
    find $out/lib/t3code -type d -name .bin -prune -exec rm -rf {} +

    # Docs, tests and TypeScript sources inside node_modules packages are
    # dead weight at run time. Keep package.json (Node resolves ESM/CJS
    # type and exports through it), LICENSE/NOTICE files and native
    # *.node/*.wasm binaries.
    for tree in $out/lib/t3code/node_modules $out/lib/t3code/apps/server/node_modules; do
      find "$tree" \( -type d \( \
             -name .github -o -name test -o -name tests -o -name __tests__ \
             -o -name example -o -name examples -o -name docs \
           \) \) -prune -exec rm -rf {} +
      find "$tree" \( -type f \( \
             -name '*.md' -o -name '*.markdown' -o -name '*.ts' \
             -o -name '*.tsbuildinfo' \
           \) \) -delete
    done

    # node-gyp intermediates: keep the compiled build/Release/*.node, drop
    # the object files, makefiles, dependency lists and bundled C sources
    # that only existed to produce it.
    find $out/lib/t3code -type d -name obj.target -prune -exec rm -rf {} +
    find $out/lib/t3code -type f -path '*/build/Makefile' -delete
    find $out/lib/t3code -type d -name .deps -path '*/build/*' -prune -exec rm -rf {} +
    find $out/lib/t3code -type d -name deps \
      -exec sh -c 'for d; do if [ -d "$d/../build/Release" ]; then rm -rf "$d"; fi; done' sh {} +

    # Native prebuilds ship one binary per platform; only linux-x64 can
    # ever be dlopened here, so drop every other target.
    find $out/lib/t3code/node_modules -type d -name prebuilds -print0 |
      while IFS= read -r -d "" d; do
        find "$d" -mindepth 1 -maxdepth 1 ! -name linux-x64 -exec rm -rf {} +
      done

    # Drop symlinks whose targets are outside the installed tree: pnpm's
    # hidden hoist references packages outside the filtered install, and the
    # workspace links point at source packages that are bundled into dist.
    find $out/lib/t3code -xtype l -delete

    # Empty out the directories the pruning left behind; this must run
    # last so it also catches the earlier steps' leftovers.
    find $out/lib/t3code -type d -empty -delete

    makeWrapper ${lib.getExe nodejs_24} $out/bin/t3 \
      --add-flags $out/lib/t3code/apps/server/dist/bin.mjs \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          opencode
          claude-code
          codex
        ]
      }

    runHook postInstall
  '';

  dontPatchELF = true;
  noAuditTmpdir = true;

  passthru.nodeModules = nodeModules;

  meta = {
    description = "Agent harness control surface: server controlling OpenCode, Claude Code, Codex and other coding agents";
    homepage = "https://github.com/pingdotgg/t3code";
    changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "t3";
    platforms = [ "x86_64-linux" ];
  };
})
