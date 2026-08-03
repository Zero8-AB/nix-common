{
  description = "Zero8 common nix utilities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    # deadnix: skip
    self,
    nixpkgs,
    flake-utils,
  }: let
    nix-lib = import ./lib/nix;
    postgres-lib = import ./lib/postgres;
    dotnet-lib = import ./lib/dotnet {inherit nix-lib;};
    go-lib = import ./lib/go {inherit nix-lib postgres-lib yaml-lib;};
    docker-lib = import ./lib/docker;
    js-lib = import ./lib/javascript {inherit nix-lib;};
    yaml-lib = import ./lib/yaml {inherit nix-lib;};
    github-lib = import ./lib/github;
    shell-lib = import ./lib/shell;
    proto-lib = import ./lib/proto {inherit yaml-lib;};
    nginx-lib = import ./lib/nginx;
    fonts-lib = import ./lib/fonts;

    prefixChecks = prefix:
      nixpkgs.lib.mapAttrs' (name: value: {
        name = "${prefix}-${name}";
        inherit value;
      });
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nix
          statix
          deadnix
          alejandra

          yamlfmt
          actionlint

          prettier
          eslint
        ];
      };

      checks =
        prefixChecks "nix" (nix-lib.mkChecks pkgs {
          src = ./.;
        })
        // {
          javascript-eslint = js-lib.mkEslint pkgs {src = ./actions;};
          javascript-prettier = js-lib.mkPrettier pkgs {src = ./actions;};
        }
        // yaml-lib.mkChecks pkgs {src = ./.github;}
        // github-lib.mkChecks pkgs {src = ./.;}
        // shell-lib.mkChecks pkgs {src = ./.;};

      formatter = pkgs.alejandra;
    })
    // {
      lib = {
        nix = nix-lib;
        dotnet = dotnet-lib;
        go = go-lib;
        docker = docker-lib;
        js = js-lib;
        yaml = yaml-lib;
        github = github-lib;
        shell = shell-lib;
        proto = proto-lib;
        nginx = nginx-lib;
        fonts = fonts-lib;
        postgres = postgres-lib;
      };
    };
}
