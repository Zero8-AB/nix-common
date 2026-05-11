pkgs: {src}:
pkgs.stdenv.mkDerivation {
  name = "proto-check";
  inherit src;
  nativeBuildInputs = with pkgs; [
    go
    buf
    protobuf
    protoc-gen-go
  ];

  buildPhase = ''
    export HOME=$(mktemp -d)
    export XDG_CACHE_HOME=$(mktemp -d)

    buf generate --output generated

    find . -name "*.pb.go" -not -path "./generated/*" | while read f; do
      generated="generated/''${f#./}"
      if ! diff -q "$f" "$generated" > /dev/null 2>&1; then
        echo "Out of date: $f — run buf generate"
        exit 1
      fi
    done
  '';

  installPhase = "mkdir -p $out";
}
