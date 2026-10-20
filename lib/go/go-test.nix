shell-lib: pkgs: {
  pname,
  version,
  src,
  subPackages,
  vendorHash ? null,
  race ? true,
}:
shell-lib.requireSuccess pkgs (pkgs.buildGoModule {
  pname = "${pname}-test";
  inherit version src vendorHash subPackages;

  nativeBuildInputs = [pkgs.gotestsum];

  checkPhase = ''
    runHook preCheck

    ${shell-lib.recordExitStatus ''
      gotestsum \
        --format testdox \
        --junitfile $out/test-results.xml \
        --jsonfile $out/report.json \
        -- ${pkgs.lib.optionalString race "-race "}-coverprofile=$out/coverage.out ./...
    ''}

    if [ -f $out/coverage.out ]; then
      go tool cover -html=$out/coverage.out -o $out/coverage.html
    fi

    runHook postCheck
  '';
})
