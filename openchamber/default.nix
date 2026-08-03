{
  appimageTools,
  fetchurl,
  lib,
  opencode,
  stdenv,
}:

let
  pname = "openchamber";
  version = "1.17.2";

  release =
    {
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-T3UYBEQmKjkvumun0UAtxI2mg/hvM1jYXVp83cnGlKo=";
      };
      x86_64-linux = {
        arch = "x86_64";
        hash = "sha256-QT0iIKl3P+XuhRdq/SN92+kVs6gDrf59vRJP6t57gn4=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/openchamber/openchamber/releases/download/v${version}/OpenChamber-${version}-linux-${release.arch}.AppImage";
    inherit (release) hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _: [ opencode ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/openchamber.desktop \
      $out/share/applications/openchamber.desktop
    install -Dm444 ${appimageContents}/openchamber.png \
      $out/share/icons/hicolor/1024x1024/apps/openchamber.png

    substituteInPlace $out/share/applications/openchamber.desktop \
      --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=openchamber %U"
  '';

  meta = {
    description = "Workspace for running, supervising, and reviewing AI coding work";
    homepage = "https://github.com/openchamber/openchamber";
    changelog = "https://github.com/openchamber/openchamber/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "openchamber";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
