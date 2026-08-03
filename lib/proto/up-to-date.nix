{yaml-lib}: pkgs: {
  root ? null,
  bufYaml ? "buf.yaml",
  bufGenYaml ? "buf.gen.yaml",
  src ? import ./source.nix {inherit yaml-lib;} pkgs {inherit root bufYaml bufGenYaml;},
  filePattern ? "*.pb.go",
  excludePaths ? [],
}: let
  generatedDir = "generated";

  gen =
    if root == null
    then
      throw ''
        mkUpToDateCheck needs `root` so the plugin list can be read from ${bufGenYaml};
        passing only `src` leaves nowhere to look for it.
      ''
    else yaml-lib.fromFile pkgs (root + "/${bufGenYaml}");

  generators =
    map (plugin: pkgs.${plugin.local})
    (builtins.filter (plugin: plugin ? local) (gen.plugins or []));

  excludeArgs =
    pkgs.lib.concatMapStringsSep " " (p: ''-not -path "${p}"'')
    (["./${generatedDir}/*" "./vendor/*"] ++ excludePaths);
in
  pkgs.stdenv.mkDerivation {
    name = "proto-up-to-date";
    inherit src;
    nativeBuildInputs = [pkgs.buf pkgs.protobuf] ++ generators;

    buildPhase = ''
      export HOME=$(mktemp -d)
      export XDG_CACHE_HOME=$(mktemp -d)

      buf generate --output ${generatedDir}

      find . -name "${filePattern}" ${excludeArgs} | while read f; do
        generated="${generatedDir}/''${f#./}"
        if ! diff -q "$f" "$generated" > /dev/null 2>&1; then
          echo "Out of date: $f — run buf generate"
          exit 1
        fi
      done
    '';

    installPhase = "mkdir -p $out";
  }
