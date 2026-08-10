{
  bun,
  callPackage,
  lib,
  makeWrapper,
  node-gyp,
  nodejs,
  opencode,
  python3,
  stdenv,
  writableTmpDirAsHomeHook,
}:

let
  common = callPackage ../openchamber/common.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "openchamber-web";
  inherit (common) version src;

  buildNodeModules = common.mkBunModules {
    pname = "${finalAttrs.pname}-build";
    installFlags = [
      "--filter"
      "openchamber-monorepo"
      "--filter"
      "@openchamber/ui"
      "--filter"
      "@openchamber/web"
      "--frozen-lockfile"
      "--ignore-scripts"
      "--linker=hoisted"
      "--no-progress"
    ];
    hash = "sha256-H3WWYgSI9g1Z6sT3sLIZCcYqkqE7FL1vCf7tJm1u7zQ=";
  };

  runtimeNodeModules = common.mkBunModules {
    pname = "${finalAttrs.pname}-runtime";
    installFlags = [
      "--filter"
      "@openchamber/web"
      "--frozen-lockfile"
      "--ignore-scripts"
      "--linker=hoisted"
      "--no-progress"
      "--production"
    ];
    hash = "sha256-3XRGQDD60MwtoEL7rwOnMeQcGeig+1EeHaQv7piSUzU=";
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

    ${common.configureNodeModules { nodeModules = finalAttrs.buildNodeModules; }}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    bun run --cwd packages/web build
    ${common.installKatexFonts}

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
