{
  callPackage,
  pyproject-build-systems,
  pyproject-nix,
  uv2nix,
  ...
}:

let
  version = "2.1.0-unstable-2026-07-04";
  source = callPackage ./source.nix { inherit version; };
  pythonEnv = callPackage ./python-env.nix {
    inherit
      pyproject-build-systems
      pyproject-nix
      source
      uv2nix
      version
      ;
  };
  camoufox = callPackage ./camoufox.nix { };
  byparr = callPackage ./package.nix {
    inherit
      camoufox
      pythonEnv
      source
      version
      ;
  };
in
{
  inherit
    byparr
    camoufox
    pythonEnv
    source
    ;

  inherit (camoufox) geolite ublockOrigin;
}
