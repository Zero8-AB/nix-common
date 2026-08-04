pkgs: {
  pname,
  version,
  src,
  nodeModules,
  pattern ? "**/*.css",
  nativeBuildInputs ? [],
  extraArgs ? [],
}:
import ./check.nix pkgs {
  inherit pname version src nodeModules nativeBuildInputs;

  name = "stylelint";
  command = "stylelint ${pkgs.lib.escapeShellArg pattern} ${pkgs.lib.escapeShellArgs extraArgs}";
}
