pkgs: {
  pname,
  version,
  src,
  nodeModules,
  nativeBuildInputs ? [],
  derivationArgs ? {},
}:
import ./check.nix pkgs {
  inherit pname version src nodeModules nativeBuildInputs derivationArgs;

  name = "size-limit";
  command = "size-limit";
}
