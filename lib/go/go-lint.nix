pkgs: {
  pname,
  version,
  src,
  subPackages,
  vendorHash ? null,
  excludePaths ? [],
}: let
  pruneArgs =
    pkgs.lib.concatMapStringsSep " "
    (p: "-path ${pkgs.lib.escapeShellArg p} -prune -o")
    (["./vendor"] ++ excludePaths);
in
  pkgs.buildGoModule {
    pname = "${pname}-lint";
    inherit version src vendorHash subPackages;

    nativeBuildInputs = [pkgs.golangci-lint pkgs.gotools pkgs.go-tools];

    checkPhase = ''
      runHook preCheck

      export HOME=$(mktemp -d)

      gofiles=$(
        find . ${pruneArgs} -name '*.go' -print |
          while IFS= read -r file; do
            if ! grep -Eq '^// Code generated .* DO NOT EDIT\.' "$file"; then
              printf '%s\n' "$file"
            fi
          done
      )

      echo "Checking files $gofiles"

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
