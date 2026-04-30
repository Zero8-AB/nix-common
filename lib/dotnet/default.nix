{nix-lib}: {
  mkNugetDepsFromLockFile = import ./packages-to-nuget-deps.nix;
  systemToRuntimeId = import ./system-to-runtime-id.nix;
  findLockfiles = {
    src,
    excludeDirs ? [".git" "node_modules" "bin" "obj"],
  }:
    nix-lib.findFiles {
      inherit src excludeDirs;
      pattern = "packages.lock.json";
    };
}
