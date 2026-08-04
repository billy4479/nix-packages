{ stdenvNoCC, version }:

let
  sourceTree = builtins.fetchTree {
    type = "github";
    owner = "ThePhaseless";
    repo = "Byparr";
    rev = "c42a353b8ac1962321e43620cda1fa44d8c49fac";
    narHash = "sha256-4PhugoO8ufwv84cxv5mMCHYsqkRwtXyHnqzb2v7ARMk=";
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
