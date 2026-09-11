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
        set -euo pipefail

        if [ ! -d "$src/.github/workflows" ]; then
          echo "No .github/workflows directory found; skipping actionlint."
          touch $out
          exit 0
        fi

        args=(-shellcheck ${pkgs.lib.getExe pkgs.shellcheck})
        for f in "$src/.github/actionlint.yaml" "$src/.github/actionlint.yml"; do
          if [ -f "$f" ]; then
            args+=(-config-file "$f")
            break
          fi
        done

        find "$src/.github/workflows" -maxdepth 1 \
          \( -name '*.yml' -o -name '*.yaml' \) \
          -exec actionlint "''${args[@]}" {} +

        touch $out
      '';
  };
}
