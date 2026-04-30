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
    nix-checks = import ./lib/nix/checks.nix {inherit nixpkgs;};
    findFiles = import ./lib/nix/findFiles.nix {inherit nixpkgs;};
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

      checks = nix-checks system {
        src = ./.;
      };
    })
    // {
      lib = {
        nix = {
          checks = nix-checks;
        };
        dotnet = {
          nuget-packagesLock2Nix = import ./lib/dotnet/nuget-packageslock2nix.nix {inherit nixpkgs;};
          getRuntimeId = import ./lib/dotnet/runtimeid.nix;

          findLockfiles = {
            src,
            excludeDirs ? [".git" "node_modules" "bin" "obj"],
          }:
            findFiles {
              inherit src excludeDirs;
              pattern = "packages.lock.json";
            };
        };
      };
    };
}
