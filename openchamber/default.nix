{
  bun,
  callPackage,
  copyDesktopItems,
  electron_41,
  lib,
  makeDesktopItem,
  makeWrapper,
  node-gyp,
  nodejs,
  opencode,
  python3,
  stdenv,
  writableTmpDirAsHomeHook,
}:

let
  common = callPackage ./common.nix { };
  electron = electron_41;
  electronBuilderArch =
    {
      aarch64-linux = "arm64";
      x86_64-linux = "x64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  electronOutput = if stdenv.hostPlatform.isAarch64 then "linux-arm64-unpacked" else "linux-unpacked";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "openchamber";
  inherit (common) version src;

  postPatch = ''
    substituteInPlace packages/electron/main.mjs \
      --replace-fail \
        "const isDev = process.env.OPENCHAMBER_ELECTRON_DEV === '1' || !app.isPackaged;" \
        $'const nixResourceRoot = process.env.OPENCHAMBER_NIX_RESOURCE_ROOT?.trim();\nconst isNixPackage = Boolean(nixResourceRoot);\nconst isDev = process.env.OPENCHAMBER_ELECTRON_DEV === "1" || (!app.isPackaged && !isNixPackage);' \
      --replace-fail \
        "const APP_USER_MODEL_ID = app.isPackaged ? PACKAGED_APP_USER_MODEL_ID : DEV_APP_USER_MODEL_ID;" \
        "const APP_USER_MODEL_ID = (app.isPackaged || isNixPackage) ? PACKAGED_APP_USER_MODEL_ID : DEV_APP_USER_MODEL_ID;" \
      --replace-fail \
        "const resourceRoot = () => isDev ? path.join(__dirname, 'resources') : process.resourcesPath;" \
        "const resourceRoot = () => nixResourceRoot || (isDev ? path.join(__dirname, 'resources') : process.resourcesPath);" \
      --replace-fail \
        "path.join(process.resourcesPath, 'icons', iconFileName)" \
        "path.join(resourceRoot(), 'icons', iconFileName)"
  '';

  nodeModules = common.mkBunModules {
    pname = finalAttrs.pname;
    nativeBuildInputs = [ nodejs ];
    installFlags = [
      "--frozen-lockfile"
      "--ignore-scripts"
      "--no-progress"
    ];
    copyWorkspaceModules = true;
    hash =
      {
        x86_64-linux = "sha256-RJoVUH7x0wfSHUWjecNirvdBnjuTZNL1b5gdcrOJyOM=";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  nativeBuildInputs = [
    bun
    copyDesktopItems
    makeWrapper
    node-gyp
    nodejs
    python3
    writableTmpDirAsHomeHook
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  configurePhase = ''
    runHook preConfigure

    ${common.configureNodeModules {
      nodeModules = finalAttrs.nodeModules;
      copyWorkspaceModules = true;
    }}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    bun run --cwd packages/web build
    ${common.installKatexFonts}
    cp -R packages/web/dist packages/electron/resources/web-dist
    bun packages/electron/scripts/bundle-main.mjs

    nodeGypFlags=(
      --nodedir=${electron.headers}
      --target=${electron.version}
      --runtime=electron
      --build-from-source
      --jobs="''${NIX_BUILD_CORES:-1}"
    )
    nodeGyp=(
      ${lib.getExe nodejs}
      ${node-gyp}/lib/node_modules/node-gyp/bin/node-gyp.js
    )
    "''${nodeGyp[@]}" rebuild --directory=node_modules/node-pty "''${nodeGypFlags[@]}"

    cp -R ${electron.dist} electron-dist
    chmod -R u+w electron-dist
    electronDist=$PWD/electron-dist
    pushd packages/electron
    node_modules/.bin/electron-builder --dir --linux --${electronBuilderArch} --publish=never \
      --config.npmRebuild=false \
      --config.electronDist="$electronDist" \
      --config.electronVersion=${electron.version}
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/openchamber
    cp -R packages/electron/dist/${electronOutput}/resources $out/share/openchamber

    makeWrapper ${lib.getExe electron} $out/bin/openchamber \
      --inherit-argv0 \
      --add-flags $out/share/openchamber/resources/app.asar \
      --prefix PATH : ${lib.makeBinPath [ opencode ]} \
      --set OPENCHAMBER_NIX_RESOURCE_ROOT $out/share/openchamber/resources \
      --set OPENCHAMBER_ELECTRON_USE_BUNDLED_UI 1 \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    install -Dm444 packages/electron/resources/icons/icon.png \
      $out/share/icons/hicolor/1024x1024/apps/openchamber.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "openchamber";
      desktopName = "OpenChamber";
      comment = finalAttrs.meta.description;
      exec = "openchamber %U";
      icon = "openchamber";
      startupWMClass = "openchamber";
      categories = [ "Development" ];
      terminal = false;
    })
  ];

  dontPatchELF = true;
  noAuditTmpdir = true;

  passthru.nodeModules = finalAttrs.nodeModules;

  meta = {
    description = "Workspace for running, supervising, and reviewing AI coding work";
    homepage = "https://github.com/openchamber/openchamber";
    changelog = "https://github.com/openchamber/openchamber/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "openchamber";
    platforms = [ "x86_64-linux" ];
  };
})
