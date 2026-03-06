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

    server-tool = {
      url = "github:billy4479/server-tool";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    mc-runner = {
      url = "github:billy4479/mc-runner";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    ff = {
      url = "git+ssh://git@github.com/billy4479/ff.git?ref=master&shallow=1";
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
        packages =
          let
            inherit (pkgs) callPackage;
          in
          {
            apple-fonts = callPackage ./apple-fonts { };
            google-sans = callPackage ./google-sans { };
            qimgv-qt6 = callPackage ./qimgv-qt6 { };
            prefetch-all-images = callPackage ./prefetch-all-images { };
            libvpl-tools = callPackage ./libvpl-tools { };
            mc-router = callPackage ./mc-router { };

            server-tool = inputs.server-tool.packages.${system}.server-tool;
            calendar-proxy = inputs.calendar-proxy.packages.${system}.default;

            mc-runner = inputs.mc-runner.packages.${system}.mc-runner;
            mc-java = inputs.mc-runner.packages.${system}.mc-java;

            ff = inputs.ff.packages.${system}.default;
          };

        devShell = pkgs.mkShell {
          packages = with pkgs; [ nixd ];
        };
      }
    );
}
