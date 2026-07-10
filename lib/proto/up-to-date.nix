pkgs: {
  root ? null,
  bufYaml ? "buf.yaml",
  bufGenYaml ? "buf.gen.yaml",
  src ? import ./source.nix pkgs {inherit root bufYaml bufGenYaml;},
  generators ? [pkgs.protoc-gen-go pkgs.protoc-gen-go-grpc],
  filePattern ? "*.pb.go",
  excludePaths ? ["./generated/*" "./vendor/*"],
}: let
  excludeArgs = pkgs.lib.concatMapStringsSep " " (p: ''-not -path "${p}"'') excludePaths;
in
  pkgs.stdenv.mkDerivation {
    name = "proto-up-to-date";
    inherit src;
    nativeBuildInputs = [pkgs.buf pkgs.protobuf] ++ generators;

    buildPhase = ''
      export HOME=$(mktemp -d)
      export XDG_CACHE_HOME=$(mktemp -d)

      buf generate --output generated

      find . -name "${filePattern}" ${excludeArgs} | while read f; do
        generated="generated/''${f#./}"
        if ! diff -q "$f" "$generated" > /dev/null 2>&1; then
          echo "Out of date: $f — run buf generate"
          exit 1
        fi
      done
    '';

    installPhase = "mkdir -p $out";
  }
