{
  bun,
  fetchFromGitHub,
  lib,
  stdenv,
  writableTmpDirAsHomeHook,
}:

rec {
  version = "1.24.2";

  src = fetchFromGitHub {
    owner = "openchamber";
    repo = "openchamber";
    tag = "v${version}";
    hash = "sha256-89hKIXndRBfLOzFPmeYA/Hnl7mUIFGB3hlpjdUcmhLI=";
  };

  mkBunModules =
    {
      pname,
      hash,
      installFlags ? [ ],
      nativeBuildInputs ? [ ],
      copyWorkspaceModules ? false,
    }:
    stdenv.mkDerivation {
      pname = "${pname}-node-modules";
      inherit version src;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ] ++ nativeBuildInputs;

      env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

      dontConfigure = true;
      dontFixup = true;

      buildPhase = ''
        runHook preBuild

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
        bun install ${lib.escapeShellArgs installFlags}

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -R node_modules $out/node_modules
        ${lib.optionalString copyWorkspaceModules ''
          for modules in packages/*/node_modules; do
            package=$(basename "$(dirname "$modules")")
            mkdir -p "$out/packages/$package"
            cp -R "$modules" "$out/packages/$package"
          done
        ''}

        runHook postInstall
      '';

      outputHashMode = "recursive";
      outputHash = hash;
    };

  configureNodeModules =
    {
      nodeModules,
      copyWorkspaceModules ? false,
    }:
    ''
      cp -R ${nodeModules}/node_modules .
      ${lib.optionalString copyWorkspaceModules ''
        for modules in ${nodeModules}/packages/*/node_modules; do
          package=$(basename "$(dirname "$modules")")
          cp -R "$modules" "packages/$package"
        done
      ''}
      chmod -R u+w node_modules
      patchShebangs node_modules
      node fix-deprecation.js
    '';

  installKatexFonts = ''
    katexFonts=node_modules/katex/dist/fonts
    if ! test -d "$katexFonts"; then
      katexFonts=packages/ui/node_modules/katex/dist/fonts
    fi
    mkdir -p packages/web/dist/assets/fonts
    cp -R "$katexFonts"/. packages/web/dist/assets/fonts
  '';
}
