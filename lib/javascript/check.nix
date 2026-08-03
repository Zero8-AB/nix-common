pkgs: {
  name,
  pname,
  version,
  src,
  command,
  nodeModules,
  nativeBuildInputs ? [],
  derivationArgs ? {},
  installPhase ? "touch $out",
}:
pkgs.stdenv.mkDerivation ({
    pname = "${pname}-${name}";
    inherit version src;

    nativeBuildInputs = [pkgs.nodejs pkgs.lndir] ++ nativeBuildInputs;

    CI = "true";

    configurePhase = ''
      runHook preConfigure

      ${import ./link-modules.nix nodeModules}

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)
      export PATH="$PWD/node_modules/.bin:$PATH"

      ${command}

      runHook postBuild
    '';

    inherit installPhase;

    dontFixup = true;
  }
  // derivationArgs)
