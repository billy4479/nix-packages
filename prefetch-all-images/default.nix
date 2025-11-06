{
  stdenvNoCC,
  makeWrapper,
  lib,
  nix-prefetch-docker,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "prefetch-all-images";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = # sh
    ''
      install -Dv ${./prefetch-all-images} $out/bin/$name

      wrapProgram $out/bin/$name \
      --prefix PATH : ${
        lib.makeBinPath [
          nix-prefetch-docker
        ]
      }
    '';
}
