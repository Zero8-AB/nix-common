pkgs: file:
builtins.fromJSON (builtins.readFile (
  pkgs.runCommand "${baseNameOf file}.json" {
    nativeBuildInputs = [pkgs.yq-go];
  } "yq -o=json '.' ${file} > $out"
))
