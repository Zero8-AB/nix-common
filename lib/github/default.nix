{
  mkChecks = pkgs: {src}: let
    fs = pkgs.lib.fileset;
    ghSrc =
      if builtins.pathExists (src + "/.github")
      then
        fs.toSource {
          root = src;
          fileset = src + "/.github";
        }
      else src;
  in {
    actionlint =
      pkgs.runCommand "github-actions-lint-check" {
        nativeBuildInputs = [pkgs.actionlint];
        src = ghSrc;
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
