{
  mkChecks = import ./checks.nix;
  findFiles = import ./find-files.nix;
  prettyPrintCheck = import ./pretty-print-check.nix;
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
