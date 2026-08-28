{
  mkChecks = pkgs: {src}: {
    gitleaks =
      pkgs.runCommand "gitleaks-check" {
        nativeBuildInputs = [pkgs.gitleaks];
        inherit src;
      } ''
        set -euo pipefail
        cp -r "$src" repo
        chmod -R +w repo
        cd repo
        gitleaks dir . --redact --no-banner

        touch $out
      '';
  };
}
