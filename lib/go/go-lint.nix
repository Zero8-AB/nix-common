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

  nativeBuildInputs = [pkgs.golangci-lint pkgs.gotools pkgs.go-tools];

  checkPhase = ''
    runHook preCheck

    export HOME=$(mktemp -d)

    gofiles=$(find . -path ./vendor -prune -o -name '*.go' -print)
    if [ -n "$gofiles" ]; then
      unformatted=$(gofmt -l $gofiles)
      if [ -n "$unformatted" ]; then
        echo "gofmt: the following files are not formatted:" >&2
        echo "$unformatted" >&2
        exit 1
      fi

      imports=$(goimports -l $gofiles)
      if [ -n "$imports" ]; then
        echo "goimports: the following files have unorganized imports:" >&2
        echo "$imports" >&2
        exit 1
      fi
    fi

    go vet ./...
    golangci-lint run ./...
    staticcheck ./...

    runHook postCheck
  '';

  installPhase = "touch $out";
}
