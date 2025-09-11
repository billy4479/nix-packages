{
  description = "My nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        formatter = pkgs.alejandra;

        packages = {
          packwiz-installer = pkgs.callPackage ./packwiz-installer { };
          apple-fonts = pkgs.callPackage ./apple-fonts { };
          google-sans = pkgs.callPackage ./google-sans { };
        };

        devShell = pkgs.mkShell {
          packages = with pkgs; [ nixd ];
        };
      }
    );
}
