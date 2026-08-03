pkgs: {
  pname,
  version,
  src,
  nativeBuildInputs ? [],
  derivationArgs ? {},
}:
pkgs.stdenv.mkDerivation ({
    pname = "${pname}-node-modules";
    inherit version src;

    nativeBuildInputs = [pkgs.nodejs] ++ nativeBuildInputs;

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      trees=$(find . -name node_modules -type d -prune -printf '%P\n')

      for tree in $trees; do
        mkdir -p "$out/$(dirname "$tree")"
        mv "$tree" "$out/$tree"
      done

      runHook postInstall
    '';

    dontFixup = true;
  }
  // derivationArgs)
