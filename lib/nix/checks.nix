{nixpkgs}: system: {
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
  }
