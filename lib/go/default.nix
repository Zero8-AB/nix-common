{
  nix-lib,
  postgres-lib,
}: {
  mkGoBuild = import ./go-build.nix;
  mkGoTest = import ./go-test.nix;
  mkGoLint = import ./go-lint.nix {inherit nix-lib;};
  mkProtoCheck = import ./go-proto.nix;
  mkSqlcCheck = import ./go-sqlc.nix;
  mkSqlcAnalysis = import ./go-sqlc-analysis.nix {inherit nix-lib postgres-lib;};
}
