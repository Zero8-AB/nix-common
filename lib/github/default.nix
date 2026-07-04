{
  mkChecks = pkgs: {src}: {
    actionlint =
      pkgs.runCommand "github-actions-lint-check" {
        nativeBuildInputs = [pkgs.actionlint];
        inherit src;
      } ''
        if [ -d "$src/.github/workflows" ]; then
          find "$src/.github/workflows" -maxdepth 1 \
            \( -name '*.yml' -o -name '*.yaml' \) \
            -exec actionlint {} +
        else
          echo "No .github/workflows directory found; skipping actionlint."
        fi

        touch $out
      '';
  };
}
