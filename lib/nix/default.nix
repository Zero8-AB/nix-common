{
  mkChecks = import ./checks.nix;
  findFiles = import ./find-files.nix;
  path.toRelative = {
    base,
    path,
  }: let
    baseString = toString base;
    pathString = toString path;

    prefixLength = builtins.stringLength baseString + 1;
  in
    builtins.substring prefixLength
    (builtins.stringLength pathString - prefixLength)
    pathString;
}
