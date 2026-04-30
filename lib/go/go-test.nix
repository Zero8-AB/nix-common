pkgs: {
  pname,
  version,
  src,
  subPackages,
  vendorHash ? null,
}:
pkgs.buildGoModule {
  pname = "${pname}-test";
  inherit version src vendorHash subPackages;

  nativeBuildInputs = [pkgs.gotestsum];

  checkPhase = ''
    runHook preCheck

    gotestsum \
      --format testdox \
      --junitfile $out/test-results.xml \
      --jsonfile $out/report.json \
      -- -race -coverprofile=$out/coverage.out ./...

    go tool cover -html=$out/coverage.out -o $out/coverage.html

    runHook postCheck
  '';
}
