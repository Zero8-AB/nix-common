{
  mkChecks = pkgs: {src}: {
    shellcheck =
      pkgs.runCommand "shellcheck" {
        nativeBuildInputs = [pkgs.shellcheck];
        inherit src;
      } ''
        set -euo pipefail
        find "$src" -name '*.sh' -exec shellcheck {} +
        touch $out
      '';
  };
}
