pkgs: {
  pname,
  version,
  src,
  nodeModules,
  nativeBuildInputs ? [],
}:
import ./check.nix pkgs {
  inherit pname version src nodeModules nativeBuildInputs;

  name = "knip";
  command = "knip";
}
