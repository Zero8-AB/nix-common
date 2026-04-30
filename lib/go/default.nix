{
  mkGoBuild = import ./go-build.nix;
  mkGoTest = import ./go-test.nix;
  mkGoLint = import ./go-lint.nix;
}
