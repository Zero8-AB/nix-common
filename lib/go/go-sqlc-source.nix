pkgs: {
  root,
  config,
}: let
  inherit (pkgs) lib;
  fs = lib.fileset;

  configFile = root + "/${config}";
  configJson =
    pkgs.runCommand "${config}.json" {
      nativeBuildInputs = [pkgs.yq-go];
    } "yq -o=json '.' ${configFile} > $out";
  cfg = builtins.fromJSON (builtins.readFile configJson);

  targets = lib.unique (
    builtins.concatMap (
      s:
        lib.toList (s.schema or [])
        ++ lib.toList (s.queries or [])
        ++ lib.optional (s ? gen.go.out) s.gen.go.out
    ) (cfg.sql or [])
  );
in
  fs.toSource {
    inherit root;
    fileset = fs.unions ([configFile] ++ map (p: root + "/${p}") targets);
  }
