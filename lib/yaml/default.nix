{nix-lib}: {
  mkChecks = pkgs: {
    src,
    config ? null,
    exclude ? [],
  }: let
    fs = pkgs.lib.fileset;

    yamlFiles = fs.fileFilter (file: file.hasExt "yaml" || file.hasExt "yml") src;
    excluded =
      builtins.filter builtins.pathExists (map (p: src + "/${p}") exclude);
    configFiles =
      builtins.filter builtins.pathExists
      (map (f: src + "/${f}") [".yamlfmt" ".yamlfmt.yaml" ".yamlfmt.yml"]);
    yamlSrc = fs.toSource {
      root = src;
      fileset = fs.unions (
        [(fs.difference yamlFiles (fs.unions excluded))] ++ configFiles
      );
    };

    files =
      nix-lib.findFiles {
        src = yamlSrc;
        pattern = name:
          builtins.match ".*\\.(yml|yaml)$" name != null;
      };

    hasConfig =
      builtins.pathExists (yamlSrc + "/.yamlfmt")
      || builtins.pathExists (yamlSrc + "/.yamlfmt.yaml")
      || builtins.pathExists (yamlSrc + "/.yamlfmt.yml");

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
            base = yamlSrc;
            path = file;
          }
      )
      files;

    fileList = pkgs.writeText "yaml-files.txt" (
      builtins.concatStringsSep "\n" relativeFiles
    );
  in {
    yaml-formatting =
      pkgs.runCommand "yaml-formatting-check" {
        nativeBuildInputs = [
          pkgs.yamlfmt
        ];
      } ''
        cd ${yamlSrc}

        if [ -s ${fileList} ]; then
          xargs --no-run-if-empty yamlfmt -lint ${configArg} < ${fileList}
        else
          echo "No YAML files found; skipping yamlfmt."
        fi

        touch $out
      '';
  };
}
