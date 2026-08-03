{yaml-lib}: pkgs: {
  root,
  config,
}: let
  inherit (pkgs) lib;
  fs = lib.fileset;

  configFile = root + "/${config}";
  cfg = yaml-lib.fromFile pkgs configFile;

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
