pkgs: {
  root,
  paths ? ["cmd" "internal" "gen"],
}: let
  fs = pkgs.lib.fileset;
in
  fs.toSource {
    inherit root;
    fileset = fs.unions (
      map (p: root + "/${p}") (["go.mod" "go.sum" "vendor"] ++ paths)
    );
  }
