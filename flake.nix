{
  description = "My nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages =
          let
            inherit (pkgs) callPackage;
          in
          rec {
            apple-fonts = callPackage ./apple-fonts { };
            google-sans = callPackage ./google-sans { };
            prefetch-all-images = callPackage ./prefetch-all-images { };
            libvpl-tools = callPackage ./libvpl-tools { };
            mc-router = callPackage ./mc-router { };

            caveclient = callPackage ./caveclient { };
            standard_transform = callPackage ./standard_transform { };
            microns-datacleaner = callPackage ./microns-datacleaner { inherit caveclient standard_transform; };
          };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ nixd ];
        };
      }
    );
}
