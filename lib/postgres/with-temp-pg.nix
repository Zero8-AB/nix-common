pkgs: {
  name ? "with-temporary-postgres-database",
  src,
  databaseName ? "test",
  postgresql ? pkgs.postgresql,
  nativeBuildInputs ? [],
  setupPhase ? "",
  checkPhase,
  installPhase ? ''
    mkdir -p "$out"

    if [ -f "$TMPDIR/postgres.log" ]; then
      mkdir -p "$out/logs"
      cp "$TMPDIR/postgres.log" "$out/logs/postgres.log"
    fi
  '',
}:
pkgs.stdenvNoCC.mkDerivation {
  inherit name src;

  nativeBuildInputs =
    [
      postgresql
    ]
    ++ nativeBuildInputs;

  dontConfigure = true;
  dontBuild = true;
  doCheck = true;

  checkPhase = ''
    set -euo pipefail

    export HOME="$TMPDIR/home"
    export XDG_CACHE_HOME="$TMPDIR/cache"
    mkdir -p "$HOME" "$XDG_CACHE_HOME"

    cp -R "$src" source
    chmod -R u+w source
    cd source

    export PGDATA="$TMPDIR/pgdata"

    initdb --no-locale --encoding=UTF8 -U postgres

    pg_ctl start \
      -l "$TMPDIR/postgres.log" \
      -o "-k $TMPDIR -F" \
      || { cat "$TMPDIR/postgres.log"; exit 1; }

    trap 'pg_ctl stop -m fast || true' EXIT

    until pg_isready -h "$TMPDIR" -U postgres -q; do
      sleep 0.1
    done

    createdb -h "$TMPDIR" -U postgres "${databaseName}"

    export PGHOST="$TMPDIR"
    export PGUSER="postgres"
    export PGDATABASE="${databaseName}"
    export DATABASE_URL="postgres://postgres@/${databaseName}?host=$TMPDIR&sslmode=disable"

    ${setupPhase}

    ${checkPhase}
  '';

  inherit installPhase;
}
