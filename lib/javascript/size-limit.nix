pkgs: {
  pname,
  version,
  src,
  nodeModules,
  nativeBuildInputs ? [],
  derivationArgs ? {},
  extraArgs ? [],
}:
import ./check.nix pkgs {
  inherit pname version src nodeModules nativeBuildInputs derivationArgs;

  name = "size-limit";
  command = "size-limit ${pkgs.lib.escapeShellArgs extraArgs}";
}
