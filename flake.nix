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
        formatter = pkgs.alejandra;

        packages = {
          packwiz-installer = pkgs.callPackage ./packwiz-installer { };
          apple-fonts = pkgs.callPackage ./apple-fonts { };
          google-sans = pkgs.callPackage ./google-sans { };
          qimgv-qt6 = pkgs.callPackage ./qimgv-qt6 { };
        };

        devShell = pkgs.mkShell {
          packages = with pkgs; [ nixd ];
        };
      }
    );
}
