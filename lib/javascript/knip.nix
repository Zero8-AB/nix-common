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

  name = "knip";
  command = "knip ${pkgs.lib.escapeShellArgs extraArgs}";
}
