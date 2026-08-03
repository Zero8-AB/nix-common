pkgs: {
  pname,
  version,
  src,
  nodeModules,
  nativeBuildInputs ? [],
}:
import ./check.nix pkgs {
  inherit pname version src nodeModules nativeBuildInputs;

  name = "typecheck";
  command = "tsc --build";
}
