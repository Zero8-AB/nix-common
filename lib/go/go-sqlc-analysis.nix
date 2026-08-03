{
  nix-lib,
  postgres-lib,
  yaml-lib,
}: pkgs: {
  root ? null,
  config ? "sqlc.analysis.yaml",
  src ? import ./go-sqlc-source.nix {inherit yaml-lib;} pkgs {inherit root config;},
}: let
  cfg = yaml-lib.fromFile pkgs (root + "/${config}");

  schemas = pkgs.lib.unique (
    builtins.concatMap (sql: pkgs.lib.toList (sql.schema or [])) (cfg.sql or [])
  );

  migrationsPath =
    if builtins.length schemas == 1
    then builtins.head schemas
    else
      throw ''
        ${config} declares ${toString (builtins.length schemas)} schema paths, but the
        migration step needs exactly one directory to run `migrate -path` against.
      '';

  withPgDatabase = postgres-lib.withTempPostgres pkgs;
  goMigratePostgres = pkgs.go-migrate.overrideAttrs (_: {
    tags = ["postgres"];
  });
  prettyPrintCheck = nix-lib.prettyPrintCheck {inherit (pkgs) lib;};
in
  withPgDatabase {
    name = "sqlc-live-analysis";
    inherit src;

    nativeBuildInputs = [
      pkgs.sqlc
      goMigratePostgres
    ];

    setupPhase = ''
      migrate \
        -path ${migrationsPath} \
        -database "$DATABASE_URL" \
        up
    '';

    checkPhase = prettyPrintCheck {
      title = "SQLC VET FAILED";
      command = "sqlc vet -f ${config}";
    };
  }
