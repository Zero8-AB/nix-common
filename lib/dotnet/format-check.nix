{
  pkgs,
  src,
  dotnet-sdk,
  dotnet-runtime,
  nugetDeps,
  runtimeId,
  projectFile,
  version ? "0",
  pname ? "dotnet-format",
}:
pkgs.buildDotnetModule {
  inherit pname version src nugetDeps projectFile dotnet-sdk dotnet-runtime runtimeId;

  buildPhase = ''
    runHook preBuild
    dotnet format "${projectFile}" --verify-no-changes --no-restore
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    runHook postInstall
  '';
}
