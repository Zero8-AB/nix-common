{yaml-lib}: pkgs: {
  root,
  bufYaml ? "buf.yaml",
  bufGenYaml ? "buf.gen.yaml",
}: let
  inherit (pkgs) lib;
  fs = lib.fileset;

  fromYaml = yaml-lib.fromFile pkgs;

  bufYamlFile = root + "/${bufYaml}";
  bufGenFile = root + "/${bufGenYaml}";
  buf = fromYaml bufYamlFile;
  gen = fromYaml bufGenFile;

  targets = lib.unique (
    map (m: m.path) (buf.modules or [])
    ++ map (p: p.out) (gen.plugins or [])
  );
in
  fs.toSource {
    inherit root;
    fileset = fs.unions ([bufYamlFile bufGenFile] ++ map (p: root + "/${p}") targets);
  }
