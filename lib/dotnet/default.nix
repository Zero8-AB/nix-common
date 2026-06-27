{nix-lib}: {
  mkNugetDepsFromLockFile = import ./packages-to-nuget-deps.nix;
  systemToRuntimeId = import ./system-to-runtime-id.nix;
  packageNuget = import ./package-nuget.nix;
  formatCheck = import ./format-check.nix;
  dotnetVersion = import ./dotnet-version.nix;
  findLockFiles = {
    src,
    excludeDirs ? [".git" "node_modules" "bin" "obj"],
  }:
    nix-lib.findFiles {
      inherit src excludeDirs;
      pattern = "packages.lock.json";
    };
}
