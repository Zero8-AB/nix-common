{
  mkChecks = {pkgs}: {
    lint =
      pkgs.runCommand "github-actions-lint-check" {
        nativeBuildInputs = [
          pkgs.actionlint
        ];
      } ''
        if [ -d .github/workflows ]; then
          actionlint
        else
          echo "No .github/workflows directory found; skipping actionlint."
        fi

        touch $out
      '';
  };
}
