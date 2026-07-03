pkgs: {
  src,
  excludePaths ? ["./generated/*" "./vendor/*"],
}: let
  excludeArgs = pkgs.lib.concatMapStringsSep " " (p: ''-not -path "${p}"'') excludePaths;
in
  pkgs.stdenv.mkDerivation {
    name = "proto-check";
    inherit src;
    nativeBuildInputs = with pkgs; [
      go
      buf
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
    ];

    buildPhase = ''
      export HOME=$(mktemp -d)
      export XDG_CACHE_HOME=$(mktemp -d)

      buf generate --output generated

      find . -name "*.pb.go" ${excludeArgs} | while read f; do
        generated="generated/''${f#./}"
        if ! diff -q "$f" "$generated" > /dev/null 2>&1; then
          echo "Out of date: $f — run buf generate"
          exit 1
        fi
      done
    '';

    installPhase = "mkdir -p $out";
  }
