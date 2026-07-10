pkgs: {
  src,
  enableStatix ? true,
  enableDeadnix ? true,
}: let
  inherit (pkgs) lib;
  fs = lib.fileset;
  nixSrc = fs.toSource {
    root = src;
    fileset = fs.fileFilter (file: file.hasExt "nix") src;
  };
in
  lib.optionalAttrs enableStatix {
    statix =
      pkgs.runCommand "statix-check" {
        nativeBuildInputs = [pkgs.statix];
      } ''
        set -euo pipefail
        cp -r ${nixSrc} repo
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
        cp -r ${nixSrc} repo
        chmod -R +w repo
        cd repo
        deadnix -f .
        mkdir -p $out
      '';
  }
