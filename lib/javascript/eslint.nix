nix-lib: pkgs: {
  src,
  pname ? null,
  version ? null,
  nodeModules ? null,
  config ? null,
  pattern ? name:
    builtins.match ".*\\.(js|cjs|mjs)$" name != null,
  nativeBuildInputs ? [],
}: let
  hasConfig =
    builtins.pathExists (src + "/eslint.config.js")
    || builtins.pathExists (src + "/eslint.config.mjs")
    || builtins.pathExists (src + "/eslint.config.cjs");

  defaultConfig = pkgs.writeText "eslint.config.mjs" ''
    export default [
      {
        files: ["**/*.js", "**/*.cjs", "**/*.mjs"],
        languageOptions: {
          ecmaVersion: 2022,
          sourceType: "commonjs",
          globals: {
            console: "readonly",
            process: "readonly",
            require: "readonly",
            __dirname: "readonly",
            __filename: "readonly",
            Buffer: "readonly",
          },
        },
        rules: {
          "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
          "no-undef": "error",
          "no-console": "off",
          "eqeqeq": ["error", "always"],
          "curly": ["error", "all"]
        },
      },
    ];
  '';

  configArg =
    if config != null
    then "--config ${toString config}"
    else if hasConfig
    then ""
    else "--config ${defaultConfig}";

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

  fileList = pkgs.writeText "eslint-files.txt" (
    builtins.concatStringsSep "\n" relativeFiles
  );
in
  if nodeModules != null
  then
    import ./check.nix pkgs {
      inherit pname version src nodeModules nativeBuildInputs;

      name = "eslint";
      command = "eslint .";
    }
  else
    pkgs.runCommand "javascript-eslint-check" {
      nativeBuildInputs = [pkgs.eslint] ++ nativeBuildInputs;
    } ''
      cd ${src}

      if [ -s ${fileList} ]; then
        xargs --no-run-if-empty eslint ${configArg} < ${fileList}
      else
        echo "No JavaScript files found; skipping eslint."
      fi

      touch $out
    ''
