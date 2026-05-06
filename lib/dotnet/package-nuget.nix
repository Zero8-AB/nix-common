{
  pkgs,
  version,
  src,
  dotnet-sdk,
  nugetDeps,
  projectFile,
  pname ? "build-nuget"
}:
pkgs.buildDotnetModule {
  inherit pname version src nugetDeps projectFile dotnet-sdk;

  packNupkg = true;
  executables = [];
  createInstallableNugetSource = true;

  dontDotnetBuild = true;
  dontDotnetInstall = true;
  dontConfigure = true;
  dontInstall = true;

  buildPhase = ''
    runHook preBuild

    find . -name 'packages.lock.json' -delete

    mkdir -p $out/share

    dotnet restore "$projectFile" \
      --source "$nugetSource"

    dotnet build "$projectFile" \
      --configuration Release \
      --no-restore

    dotnet pack "$projectFile" \
      --configuration Release \
      --output "$out/share"

    runHook postBuild
  '';
}
