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

  name = "lingui-check";

  command = ''
    snapshot() {
      find . -name node_modules -prune -o -name '*.po' -exec sha256sum {} + | sort
    }

    before=$(snapshot)

    lingui extract --clean --workers 1

    if [ "$before" != "$(snapshot)" ]; then
      echo 'Message catalogs are stale, run lingui extract and commit the result.' >&2
      exit 1
    fi

    lingui compile --strict --workers 1
  '';
}
