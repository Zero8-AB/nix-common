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

  name = "typecheck";
  command = "tsc --build ${pkgs.lib.escapeShellArgs extraArgs}";
}
