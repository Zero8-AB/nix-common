system: let
  map = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "linux-arm64";
    "armv7l-linux" = "linux-arm";
    "x86_64-darwin" = "osx-x64";
    "aarch64-darwin" = "osx-arm64";
    "x86_64-windows" = "win-x64";
    "i686-windows" = "win-x86";
    "aarch64-windows" = "win-arm64";
  };
in
  map.${system}
  or (throw "systemToRuntimeId: unsupported system '${system}'. Supported: ${builtins.toString (builtins.attrNames map)}")
