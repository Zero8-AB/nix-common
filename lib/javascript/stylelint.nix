pkgs: {
  pname,
  version,
  src,
  nodeModules,
  pattern ? "**/*.css",
  nativeBuildInputs ? [],
}:
import ./check.nix pkgs {
  inherit pname version src nodeModules nativeBuildInputs;

  name = "stylelint";
  command = "stylelint ${pkgs.lib.escapeShellArg pattern}";
}
