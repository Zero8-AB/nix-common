pkgs: {
  pname,
  version,
  src,
  subPackages,
  vendorHash ? null,
}:
pkgs.buildGoModule {
  pname = "${pname}-lint";
  inherit version src vendorHash subPackages;

  nativeBuildInputs = [pkgs.golangci-lint];

  checkPhase = ''
    runHook preCheck

    export HOME=$(mktemp -d)

    golangci-lint run ./...
    go vet ./...

    runHook postCheck
  '';

  installPhase = "touch $out";
}
