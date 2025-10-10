{
  description = "My nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    calendar-proxy = {
      url = "github:billy4479/calendar-proxy";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          packwiz-installer = pkgs.callPackage ./packwiz-installer { };
          apple-fonts = pkgs.callPackage ./apple-fonts { };
          google-sans = pkgs.callPackage ./google-sans { };
          qimgv-qt6 = pkgs.callPackage ./qimgv-qt6 { };

          containers = {
            calendar-proxy = inputs.calendar-proxy.packages.${system}.container;
          };
        };

        devShell = pkgs.mkShell {
          packages = with pkgs; [ nixd ];
        };
      }
    );
}
