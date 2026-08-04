nix-lib: pkgs: {
  src,
  pname ? null,
  version ? null,
  nodeModules ? null,
  config ? null,
  pattern ? name:
    builtins.match
    ".*\\.(js|cjs|mjs|jsx|ts|cts|mts|tsx|css|scss|less|json|jsonc|html)$"
    name
    != null,
  nativeBuildInputs ? [],
  extraArgs ? [],
}: let
  configArg =
    if config != null
    then "--config ${toString config}"
    else "";

  files = nix-lib.findFiles {inherit src pattern;};

  relativeFiles =
    map (
      file:
        nix-lib.path.toRelative {
          base = src;
          path = file;
        }
    )
    files;

  fileList = pkgs.writeText "prettier-files.txt" (
    builtins.concatStringsSep "\n" relativeFiles
  );
in
  if nodeModules != null
  then
    import ./check.nix pkgs {
      inherit pname version src nodeModules nativeBuildInputs;

      name = "prettier";
      command = "prettier --check ${configArg} ${pkgs.lib.escapeShellArgs extraArgs} .";
    }
  else
    pkgs.runCommand "javascript-prettier-check" {
      nativeBuildInputs = [pkgs.prettier] ++ nativeBuildInputs;
    } ''
      cd ${src}

      if [ -s ${fileList} ]; then
        xargs --no-run-if-empty prettier --check ${configArg} ${pkgs.lib.escapeShellArgs extraArgs} < ${fileList}
      else
        echo "No formattable files found; skipping prettier."
      fi

      touch $out
    ''
