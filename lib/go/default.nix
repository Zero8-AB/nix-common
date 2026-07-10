{
  nix-lib,
  postgres-lib,
}: {
  mkGoBuild = import ./go-build.nix;
  mkGoTest = import ./go-test.nix;
  mkGoSource = import ./go-source.nix;
  mkSqlcSource = import ./go-sqlc-source.nix;
  mkGoLint = import ./go-lint.nix {inherit nix-lib;};
  mkSqlcCheck = import ./go-sqlc.nix;
  mkSqlcAnalysis = import ./go-sqlc-analysis.nix {inherit nix-lib postgres-lib;};
}
