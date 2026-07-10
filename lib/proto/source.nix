pkgs: {
  root,
  bufYaml ? "buf.yaml",
  bufGenYaml ? "buf.gen.yaml",
}: let
  inherit (pkgs) lib;
  fs = lib.fileset;

  fromYaml = name: file:
    builtins.fromJSON (builtins.readFile (
      pkgs.runCommand "${name}.json" {
        nativeBuildInputs = [pkgs.yq-go];
      } "yq -o=json '.' ${file} > $out"
    ));

  bufYamlFile = root + "/${bufYaml}";
  bufGenFile = root + "/${bufGenYaml}";
  buf = fromYaml "buf" bufYamlFile;
  gen = fromYaml "buf-gen" bufGenFile;

  targets = lib.unique (
    map (m: m.path) (buf.modules or [])
    ++ map (p: p.out) (gen.plugins or [])
  );
in
  fs.toSource {
    inherit root;
    fileset = fs.unions ([bufYamlFile bufGenFile] ++ map (p: root + "/${p}") targets);
  }
