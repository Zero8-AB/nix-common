pkgs: {
  writablePaths ? [],
  extraEnv ? [],
}: let
  passEnv = ["PATH" "TERM" "LANG" "LC_ALL" "CI"] ++ extraEnv;

  names = pkgs.lib.concatMapStringsSep " " (value: "'${value}'");
  paths = pkgs.lib.concatMapStringsSep " " (value: ''"${value}"'');
in
  pkgs.writeShellApplication {
    name = "sandbox";

    runtimeInputs = [pkgs.bubblewrap];

    text = ''
      network=0

      if [ "''${1-}" = "--network" ]; then
        network=1
        shift
      fi

      if [ "$#" -eq 0 ]; then
        echo "usage: sandbox [--network] command [args...]" >&2
        exit 2
      fi

      scratch=$(mktemp -d)
      trap 'rm -rf "$scratch"' EXIT

      args=(
        --unshare-all
        --die-with-parent
        --new-session
        --clearenv
        --setenv HOME "$scratch"
        --ro-bind /nix/store /nix/store
        --proc /proc
        --dev /dev
        --tmpfs /tmp
        --dir /bin
        --symlink ${pkgs.bash}/bin/bash /bin/sh
        --bind "$scratch" "$scratch"
        --bind "$PWD" "$PWD"
        --chdir "$PWD"
      )

      for name in ${names passEnv}; do
        if [ -n "''${!name-}" ]; then
          args+=(--setenv "$name" "''${!name}")
        fi
      done

      for path in ${paths writablePaths}; do
        args+=(--bind-try "$path" "$path")
      done

      if [ "$network" -eq 1 ]; then
        args+=(
          --share-net
          --ro-bind-try /etc/resolv.conf /etc/resolv.conf
          --ro-bind-try /etc/hosts /etc/hosts
        )

        bundle=$(readlink -f "''${SSL_CERT_FILE:-''${NIX_SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}}" 2>/dev/null || true)

        if [ -r "''${bundle:-}" ]; then
          args+=(
            --ro-bind "$bundle" "$bundle"
            --setenv SSL_CERT_FILE "$bundle"
            --setenv NIX_SSL_CERT_FILE "$bundle"
          )
        fi
      fi

      exec bwrap "''${args[@]}" -- "$@"
    '';
  }
