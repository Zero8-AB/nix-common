{
  nix-lib,
  postgres-lib,
}: pkgs: {
  src,
  sqlcConfig ? "sqlc.analysis.yaml",
  migrationsPath ? "database/migrations",
  seedSql ? null,
}: let
  withPgDatabase = postgres-lib.withTempPostgres pkgs;
  goMigratePostgres = pkgs.go-migrate.overrideAttrs (old: {
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
      command = "sqlc vet -f ${sqlcConfig}";
    };
  }
