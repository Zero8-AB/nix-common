pkgs: {
  pname,
  version,
  src,
  format ? "cyclonedx-json",
  filename ? "sbom.json",
}:
pkgs.stdenv.mkDerivation {
  pname = "${pname}-sbom";
  inherit version src;

  nativeBuildInputs = [pkgs.syft];

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    export XDG_CACHE_HOME=$(mktemp -d)
    export SYFT_CHECK_FOR_APP_UPDATE=false

    syft scan dir:. --quiet --output ${format}=${filename}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp ${filename} $out/${filename}

    runHook postInstall
  '';

  dontFixup = true;
}
