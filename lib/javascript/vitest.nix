pkgs: {
  pname,
  version,
  src,
  nodeModules,
  command ? "vitest run",
  nativeBuildInputs ? [],
  derivationArgs ? {},
  extraArgs ? [],
}: let
  resultsFile = "junit.xml";
  coverageDir = "coverage";
in
  import ./check.nix pkgs {
    inherit pname version src nodeModules nativeBuildInputs derivationArgs;

    name = "test";

    command = "${command} --outputFile.junit=${resultsFile} --coverage.reportsDirectory=${coverageDir} ${pkgs.lib.escapeShellArgs extraArgs}";

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      if [ ! -f ${resultsFile} ]; then
        echo "no junit output at ${resultsFile}; is the junit reporter enabled?" >&2
        exit 1
      fi

      cp ${resultsFile} $out/test-results.xml

      if [ -d ${coverageDir} ]; then
        cp -r ${coverageDir} $out/coverage
      fi

      runHook postInstall
    '';
  }
