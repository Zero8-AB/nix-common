{
  description = "Zero8 common nix utilities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    mkChecks = system: {
      src,
      enableStatix ? true,
      enableDeadnix ? true,
    }: let
      pkgs = import nixpkgs {inherit system;};
      inherit (pkgs) lib;
    in
      lib.optionalAttrs enableStatix {
        statix =
          pkgs.runCommand "statix-check" {
            nativeBuildInputs = [pkgs.statix];
          } ''
            set -euo pipefail
            cp -r ${src} repo
            chmod -R +w repo
            cd repo
            statix check .
            mkdir -p $out
          '';
      }
      // lib.optionalAttrs enableDeadnix {
        deadnix =
          pkgs.runCommand "deadnix-check" {
            nativeBuildInputs = [pkgs.deadnix];
          } ''
            set -euo pipefail
            cp -r ${src} repo
            chmod -R +w repo
            cd repo
            deadnix -f .
            mkdir -p $out
          '';
      };
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
    })
    // {
      lib.mkChecks = mkChecks;
    };
}
