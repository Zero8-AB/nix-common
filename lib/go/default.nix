{
  nix-lib,
  postgres-lib,
  yaml-lib,
}: {
  mkGoBuild = import ./go-build.nix;
  mkGoTest = import ./go-test.nix;
  mkGoSource = import ./go-source.nix;
  mkSqlcSource = import ./go-sqlc-source.nix {inherit yaml-lib;};
  mkGoLint = import ./go-lint.nix {inherit nix-lib;};
  mkSqlcCheck = import ./go-sqlc.nix {inherit yaml-lib;};
  mkSqlcAnalysis = import ./go-sqlc-analysis.nix {inherit nix-lib postgres-lib yaml-lib;};
}
