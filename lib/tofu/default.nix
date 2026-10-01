{
  mkChecks = pkgs: {
    src,
    exclude ? [],
    providers ? null,
    enableFormatting ? true,
    enableLint ? true,
  }: let
    inherit (pkgs) lib;
    fs = lib.fileset;

    tofuFiles = fs.fileFilter (file: file.hasExt "tf" || file.hasExt "tofu") src;

    excluded =
      builtins.filter builtins.pathExists (map (p: src + "/${p}") exclude);

    configFiles =
      builtins.filter builtins.pathExists [(src + "/.tflint.hcl")];

    tofuSrc = fs.toSource {
      root = src;
      fileset = fs.unions (
        [(fs.difference tofuFiles (fs.unions excluded))] ++ configFiles
      );
    };

    tofu = pkgs.opentofu.withPlugins providers;

    formatting =
      pkgs.runCommand "tofu-formatting-check" {
        nativeBuildInputs = [pkgs.opentofu];
      } ''
        set -euo pipefail

        cp -r ${tofuSrc} repo
        chmod -R +w repo
        cd repo

        tofu fmt -check -recursive -diff .
        touch $out
      '';

    lint =
      pkgs.runCommand "tofu-lint-check" {
        nativeBuildInputs = [pkgs.tflint];
      } ''
        set -euo pipefail

        cp -r ${tofuSrc} repo
        chmod -R +w repo
        cd repo

        export HOME="$TMPDIR"
        export TFLINT_PLUGIN_DIR="$PWD/.tflint.d"

        if test -f .tflint.hcl; then
          export TFLINT_CONFIG_FILE="$PWD/.tflint.hcl"
        fi

        find . -name '*.tf' -printf '%h\n' | sort -u | while read -r dir; do
          echo "linting $dir"
          tflint --no-color --chdir "$dir"
        done

        touch $out
      '';

    validate =
      pkgs.runCommand "tofu-validate-check" {
        nativeBuildInputs = [tofu];
      } ''
        set -euo pipefail
        export HOME="$TMPDIR"
        export TF_IN_AUTOMATION=1

        cp -r ${tofuSrc} repo
        chmod -R +w repo
        cd repo

        find . -name '*.tf' -printf '%h\n' | sort -u | while read -r dir; do
          echo "validating $dir"
          tofu -chdir="$dir" init -backend=false -input=false > /dev/null
          tofu -chdir="$dir" validate
        done

        touch $out
      '';
  in
    lib.optionalAttrs enableFormatting {tofu-formatting = formatting;}
    // lib.optionalAttrs enableLint {tofu-lint = lint;}
    // lib.optionalAttrs (providers != null) {tofu-validate = validate;};
}
