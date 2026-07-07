{ stdenvNoCC, version }:

let
  sourceTree = builtins.fetchTree {
    type = "github";
    owner = "ThePhaseless";
    repo = "Byparr";
    rev = "ecdd4c112a60c5fb22c781f142537e0b3399e568";
    narHash = "sha256-eIbWqbUNOcS0WVgszXPVIbDx0hhRH1d1o+K0JXAEdwY=";
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
