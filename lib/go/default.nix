{
  mkGoBuild = import ./go-build.nix;
  mkGoTest = import ./go-test.nix;
  mkGoLint = import ./go-lint.nix;
  mkProtoCheck = import ./go-proto.nix;
  mkSqlcCheck = import ./go-sqlc.nix;
}
