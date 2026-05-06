{nix-lib}: {
  mkChecks = {
    pkgs,
    src,
    files ?
      nix-lib.findFiles {
        inherit src;
        pattern = name:
          builtins.match ".*\\.(yml|yaml)$" name != null;
      },
    config ? null,
  }: let
    hasConfig =
      builtins.pathExists (src + "/.yamlfmt")
      || builtins.pathExists (src + "/.yamlfmt.yaml")
      || builtins.pathExists (src + "/.yamlfmt.yml");

    defaultConfig = pkgs.writeText "yamlfmt.yaml" ''
      formatter:
        type: basic
        retain_line_breaks: true
    '';

    configArg =
      if config != null
      then "-conf ${toString config}"
      else if hasConfig
      then ""
      else "-conf ${defaultConfig}";

    relativeFiles =
      map (
        file:
          nix-lib.path.toRelative {
            base = src;
            path = file;
          }
      )
      files;

    fileList = pkgs.writeText "yaml-files.txt" (
      builtins.concatStringsSep "\n" relativeFiles
    );
  in {
    formatting =
      pkgs.runCommand "yaml-formatting-check" {
        nativeBuildInputs = [
          pkgs.yamlfmt
        ];
      } ''
        cd ${src}

        if [ -s ${fileList} ]; then
          xargs --no-run-if-empty yamlfmt -lint ${configArg} < ${fileList}
        else
          echo "No YAML files found; skipping yamlfmt."
        fi

        touch $out
      '';
  };
}
