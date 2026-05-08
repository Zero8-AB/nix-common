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
    dotnet-lib = import ./lib/dotnet {inherit nix-lib;};
    go-lib = import ./lib/go;
    docker-lib = import ./lib/docker;
    js-lib = import ./lib/javascript {inherit nix-lib;};
    yaml-lib = import ./lib/yaml {inherit nix-lib;};
    github-lib = import ./lib/github;
    nginx-lib = import ./lib/nginx;

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
        // prefixChecks "javascript" (js-lib.mkChecks pkgs {
          src = ./actions;
        })
        // prefixChecks "yaml" (yaml-lib.mkChecks {
          inherit pkgs;
          src = ./.github;
        })
        // prefixChecks "github" (github-lib.mkChecks {
          inherit pkgs;
        });

      formatter = pkgs.alejandra;
    })
    // {
      lib = {
        nix = nix-lib;
        dotnet = dotnet-lib;
        go = go-lib;
        docker = docker-lib;
        js = js-lib;
        nginx = nginx-lib;
      };
    };
}
