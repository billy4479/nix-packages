{
  bun,
  fetchFromGitHub,
  lib,
  makeWrapper,
  node-gyp,
  nodejs,
  opencode,
  python3,
  stdenv,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openchamber-web";
  version = "1.17.2";

  src = fetchFromGitHub {
    owner = "openchamber";
    repo = "openchamber";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5RascQNN4C0hxuGHPtWkcxsjIlxRajJ3yt5RIKgWIks=";
  };

  buildNodeModules = stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-build-node-modules";
    inherit (finalAttrs) version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --filter openchamber-monorepo \
        --filter @openchamber/ui \
        --filter @openchamber/web \
        --frozen-lockfile \
        --ignore-scripts \
        --linker=hoisted \
        --no-progress

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out/node_modules

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-VCKLfAHGEWcEerp1ttESIBH1JqKy2VAZAUS5k22PA5o=";
  };

  runtimeNodeModules = stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-runtime-node-modules";
    inherit (finalAttrs) version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --filter @openchamber/web \
        --frozen-lockfile \
        --ignore-scripts \
        --linker=hoisted \
        --no-progress \
        --production

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out/node_modules

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-6lc1fujqV1z4OygVeCxJPAs+6GDQzRTF63tGBgZYmzg=";
  };

  nativeBuildInputs = [
    bun
    makeWrapper
    node-gyp
    nodejs
    python3
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.buildNodeModules}/node_modules .
    chmod -R u+w node_modules
    patchShebangs node_modules
    node fix-deprecation.js
    node_modules/.bin/patch-package

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    bun run --cwd packages/web build

    rm -rf node_modules
    cp -R ${finalAttrs.runtimeNodeModules}/node_modules .
    chmod -R u+w node_modules
    rm -f node_modules/.bin/openchamber node_modules/@openchamber/web
    patchShebangs node_modules
    node fix-deprecation.js

    nodeGyp=(
      ${lib.getExe nodejs}
      ${node-gyp}/lib/node_modules/node-gyp/bin/node-gyp.js
    )
    nodeGypFlags=(
      --nodedir=${nodejs}
      --build-from-source
      --jobs="''${NIX_BUILD_CORES:-1}"
    )
    "''${nodeGyp[@]}" rebuild --directory=node_modules/node-pty "''${nodeGypFlags[@]}"
    "''${nodeGyp[@]}" rebuild --release --directory=node_modules/better-sqlite3 "''${nodeGypFlags[@]}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/openchamber-web $out/bin
    cp -R node_modules $out/lib/openchamber-web/node_modules
    cp -R packages/web/{bin,dist,public,server,package.json,README.md} $out/lib/openchamber-web

    makeWrapper ${lib.getExe nodejs} $out/bin/openchamber \
      --add-flags $out/lib/openchamber-web/bin/cli.js \
      --prefix PATH : ${lib.makeBinPath [ opencode ]}

    runHook postInstall
  '';

  dontPatchELF = true;
  noAuditTmpdir = true;

  passthru = {
    inherit (finalAttrs) buildNodeModules runtimeNodeModules;
  };

  meta = {
    description = "Web server and CLI for OpenChamber";
    homepage = "https://github.com/openchamber/openchamber";
    changelog = "https://github.com/openchamber/openchamber/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "openchamber";
    platforms = [ "x86_64-linux" ];
  };
})
