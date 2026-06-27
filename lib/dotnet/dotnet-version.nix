{
  pkgs,
  src,
  dotnet-sdk,
  projectFile,
  pname ? "dotnet-version",
}: let
  versionDrv =
    pkgs.runCommand pname {
      nativeBuildInputs = [dotnet-sdk];
      inherit src;
    } ''
      set -euo pipefail

      cp -R "$src" ./src
      chmod -R u+w ./src
      cd ./src

      get_property() {
        dotnet msbuild "${projectFile}" \
          -nologo \
          -getProperty:"$1" \
          | tr -d '\r'
      }

      resolvedVersion="$(get_property Version)"

      if [ -n "$resolvedVersion" ]; then
        printf '%s' "$resolvedVersion" > "$out"
        exit 0
      fi

      prefix="$(get_property VersionPrefix)"
      suffix="$(get_property VersionSuffix)"

      if [ -z "$prefix" ]; then
        echo "No MSBuild Version or VersionPrefix found in ${projectFile}" >&2
        exit 1
      fi

      if [ -n "$suffix" ]; then
        printf '%s-%s' "$prefix" "$suffix" > "$out"
      else
        printf '%s' "$prefix" > "$out"
      fi
    '';
in
  pkgs.lib.removeSuffix "\n" (builtins.readFile versionDrv)
