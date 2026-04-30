_: {
  src,
  excludeDirs ? ["bin" "obj" "node_modules" ".git" ".github"],
}: let
  walk = dir: let
    entries = builtins.readDir dir;
    paths = builtins.attrNames entries;
    process = name: let
      type = entries.${name};
      path = dir + "/${name}";
    in
      if type == "directory" && !(builtins.elem name excludeDirs)
      then walk path
      else if type == "regular" && name == "packages.lock.json"
      then [path]
      else [];
  in
    builtins.concatLists (map process paths);
in
  walk src
