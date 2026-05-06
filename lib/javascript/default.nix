{nix-lib}: {
  mkChecks = import ./checks.nix nix-lib;
}
