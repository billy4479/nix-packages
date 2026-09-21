{
  description = "My nix packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      pyproject-build-systems,
      pyproject-nix,
      uv2nix,
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
            byparrPackages = callPackage ./byparr {
              inherit pyproject-build-systems pyproject-nix uv2nix;
            };
          in
          rec {
            google-sans = callPackage ./google-sans { };
            prefetch-all-images = callPackage ./prefetch-all-images { };
            byparr = byparrPackages.byparr;
            byparr-source = byparrPackages.source;
            byparr-python-env = byparrPackages.pythonEnv;
            byparr-stealthfox = byparrPackages.stealthfox;
            byparr-geoip = byparrPackages.geoip;
            libvpl-tools = callPackage ./libvpl-tools { };
            mc-router = callPackage ./mc-router { };
            lunamultiplayer-server = callPackage ./lunamultiplayer-server { };
            mcp-searxng = callPackage ./mcp-searxng { };
            searxng-cli = callPackage ./searxng-cli { };
            openchamber = callPackage ./openchamber { };
            openchamber-web = callPackage ./openchamber-web { };

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
