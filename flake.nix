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
        ];
      };

      checks = nix-lib.mkChecks pkgs {
        src = ./.;
      };

      formatter = pkgs.alejandra;
    })
    // {
      lib = {
        nix = nix-lib;
        dotnet = dotnet-lib;
        go = go-lib;
        docker = docker-lib;
      };
    };
}
