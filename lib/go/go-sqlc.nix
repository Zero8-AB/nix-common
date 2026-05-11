pkgs: {src}:
pkgs.stdenv.mkDerivation {
  name = "sqlc-check";
  inherit src;
  nativeBuildInputs = [pkgs.sqlc];

  buildPhase = ''
    export HOME=$(mktemp -d)
    export XDG_CACHE_HOME=$(mktemp -d)

    cp -R ${src} source
    chmod -R u+w source
    cd source

    sqlc generate

    find . -name "*.sql.go" | while read f; do
      if ! diff -q "$f" "${src}/''${f#./}" > /dev/null 2>&1; then
        echo "Out of date: $f — run sqlc generate"
        exit 1
      fi
    done
  '';

  installPhase = "mkdir -p $out";
}
