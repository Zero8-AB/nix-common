pkgs: {
  pname,
  version,
  src,
  nodeModules,
  packageVersion,
  name ? "integration-test",
  browsers ? pkgs.playwright-driver.browsers,
  driverVersion ? pkgs.playwright-driver.version,
  command ? "playwright test",
  installPhase ? ''
    runHook preInstall

    mkdir -p $out

    if [ -f "$PLAYWRIGHT_JUNIT_OUTPUT_FILE" ]; then
      cp "$PLAYWRIGHT_JUNIT_OUTPUT_FILE" $out/test-results.xml
    fi

    if [ -d "$PLAYWRIGHT_HTML_OUTPUT_DIR" ]; then
      cp -r "$PLAYWRIGHT_HTML_OUTPUT_DIR" $out/report
    fi

    runHook postInstall
  '',
  nativeBuildInputs ? [],
  derivationArgs ? {},
}:
assert pkgs.lib.assertMsg (packageVersion == driverVersion) ''
  playwright version mismatch: the project depends on ${packageVersion} but the
  pinned browsers are ${driverVersion}. Align the package version with the
  browsers, or pass a matching browsers derivation.
'';
  import ./check.nix pkgs {
    inherit name pname version src nodeModules installPhase nativeBuildInputs;

    command = ''
      export PLAYWRIGHT_BROWSERS_PATH=${browsers}
      export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true

      ${command}
    '';

    derivationArgs =
      {
        PLAYWRIGHT_JUNIT_OUTPUT_FILE = "junit.xml";
        PLAYWRIGHT_HTML_OUTPUT_DIR = "report";
      }
      // derivationArgs;
  }
