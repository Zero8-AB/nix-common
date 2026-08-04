pkgs: {
  pname,
  version,
  src,
  nodeModules,
  nativeBuildInputs ? [],
  extraArgs ? [],
}:
import ./check.nix pkgs {
  inherit pname version src nodeModules nativeBuildInputs;

  name = "oxlint";
  command = "oxlint ${pkgs.lib.escapeShellArgs extraArgs}";
}
