{ stdenvNoCC, version }:

let
  sourceTree = builtins.fetchTree {
    type = "github";
    owner = "ThePhaseless";
    repo = "Byparr";
    rev = "ceef2d66bfd24d8014a5392d5622671584fa9162";
    narHash = "sha256-6XlhQJI/TBYXbojivBp+dFXJDcuBsY6ZLwLwTw+YqMA=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "byparr-source";
  inherit version;

  passthru.sourcePath = sourceTree.outPath;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    cp -R "${sourceTree.outPath}/." "$out"
    runHook postInstall
  '';
}
