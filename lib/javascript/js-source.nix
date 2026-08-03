pkgs: {
  root,
  paths ? ["src"],
  files ? ["package.json"],
}: let
  fs = pkgs.lib.fileset;
in
  fs.toSource {
    inherit root;
    fileset = fs.unions (map (path: root + "/${path}") (files ++ paths));
  }
