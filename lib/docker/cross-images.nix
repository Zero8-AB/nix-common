{
  pkgs,
  system,
  mkImage,
}:
  if system == "x86_64-linux"
  then {
    docker-arm64 = mkImage pkgs.pkgsCross.aarch64-multiplatform;
  }
  else if system == "aarch64-linux"
  then {
    docker-amd64 = mkImage pkgs.pkgsCross.x86_64-linux;
  }
  else {}
