{
  mkChecks = import ./checks.nix;
  mkUpToDateCheck = import ./up-to-date.nix;
  mkProtoSource = import ./source.nix;
}
