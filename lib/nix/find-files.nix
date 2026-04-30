{
  src,
  pattern,
  excludeDirs ? [".git" "node_modules" "bin" "obj"],
}: let
  matches = name:
    if builtins.isString pattern
    then name == pattern
    else if builtins.isFunction pattern
    then pattern name
    else throw "findFiles: pattern must be a string or function, got ${builtins.typeOf pattern}";

  walk = dir: let
    entries = builtins.readDir dir;
    process = name: let
      type = entries.${name};
      path = dir + "/${name}";
    in
      if type == "directory" && !(builtins.elem name excludeDirs)
      then walk path
      else if type == "regular" && matches name
      then [path]
      else [];
  in
    builtins.concatLists (map process (builtins.attrNames entries));
in
  walk src
