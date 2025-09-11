{ stdenvNoCC, fetchFromGitHub, ... }:
stdenvNoCC.mkDerivation {
  pname = "google-sans";
  version = "0-unstable-2025-09-11";
  src = fetchFromGitHub {
    owner = "hprobotic";
    repo = "Google-Sans-Font";
    rev = "42c6b3e1bb33c4a9831adb3406c3b7eef47d737b";
    hash = "sha256-y5lMVJzFLhIOtph7JgYD69wH+Vd8f1JE2/Ln3EMKG38=";
  };

  dontBuild = true;
  dontFixup = true;
  dontConfigure = true;

  installPhase = # sh
    ''
      mkdir -p $out/share/fonts/truetype/Google-Sans
      chmod 644 *.ttf
      mv *.ttf $out/share/fonts/truetype/Google-Sans
    '';
}
