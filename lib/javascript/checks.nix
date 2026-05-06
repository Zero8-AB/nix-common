nix-lib: pkgs: {
  src,
  files ?
    nix-lib.findFiles {
      inherit src;
      pattern = name:
        builtins.match ".*\\.(js|cjs|mjs)$" name != null;
    },
  eslintConfig ? null,
  prettierConfig ? null,
}: let
  hasEslintConfig =
    builtins.pathExists (src + "/eslint.config.js")
    || builtins.pathExists (src + "/eslint.config.mjs")
    || builtins.pathExists (src + "/eslint.config.cjs");

  defaultEslintConfig = pkgs.writeText "eslint.config.mjs" ''
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

  eslintArgs =
    if eslintConfig != null
    then "--config ${toString eslintConfig}"
    else if hasEslintConfig
    then ""
    else "--config ${defaultEslintConfig}";

  relativeFiles =
    map (
      file:
        nix-lib.path.toRelative {
          base = src;
          path = file;
        }
    )
    files;

  fileList = pkgs.writeText "javascript-files.txt" (
    builtins.concatStringsSep "\n" relativeFiles
  );

  optionalArg = name: value:
    if value == null
    then ""
    else "--${name} ${toString value}";
in {
  formatting =
    pkgs.runCommand "javascript-formatting-check" {
      nativeBuildInputs = [
        pkgs.nodePackages.prettier
      ];
    } ''
      cd ${src}

      if [ -s ${fileList} ]; then
        xargs prettier --check ${optionalArg "config" prettierConfig} < ${fileList}
      fi

      touch $out
    '';

  lint =
    pkgs.runCommand "javascript-lint-check" {
      nativeBuildInputs = [
        pkgs.nodejs
        pkgs.nodePackages.eslint
      ];
    } ''
      cd ${src}

      if [ -s ${fileList} ]; then
        xargs eslint ${eslintArgs} < ${fileList}
      fi

      touch $out
    '';
}
