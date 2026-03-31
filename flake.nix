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

        pkgsNames = [
          "apple-fonts"
          "google-sans"
          "prefetch-all-images"
          "libvpl-tools"
          "mc-router"
          "caveclient"
        ];
      in
      {
        packages = (builtins.foldl' (p: n: p // { "${n}" = pkgs.callPackage ./${n} { }; }) { } pkgsNames);

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ nixd ];
        };
      }
    );
}
