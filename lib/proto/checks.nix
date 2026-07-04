pkgs: {src}: {
  proto-lint =
    pkgs.runCommand "proto-lint" {
      nativeBuildInputs = [pkgs.buf];
      inherit src;
    } ''
      export HOME=$(mktemp -d)
      export XDG_CACHE_HOME=$(mktemp -d)

      cp -R "$src" source
      chmod -R u+w source
      cd source

      buf lint

      touch $out
    '';

  proto-breaking =
    pkgs.runCommand "proto-breaking" {
      nativeBuildInputs = [pkgs.buf];
      inherit src;
    } ''
      export HOME=$(mktemp -d)
      export XDG_CACHE_HOME=$(mktemp -d)

      cp -R "$src" source
      chmod -R u+w source
      cd source

      if [ -d .git ]; then
        buf breaking . --against '.git#ref=HEAD~1'
      else
        echo "No .git directory found; skipping buf breaking."
      fi

      touch $out
    '';
}
