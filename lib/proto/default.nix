{yaml-lib}: {
  mkChecks = import ./checks.nix;
  mkUpToDateCheck = import ./up-to-date.nix {inherit yaml-lib;};
  mkProtoSource = import ./source.nix {inherit yaml-lib;};
}
