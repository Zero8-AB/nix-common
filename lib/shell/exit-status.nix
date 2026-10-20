{
  recordExitStatus = command: ''
    set +e
    (
      set -e
      ${command}
    )
    status=$?
    set -e

    mkdir -p "$out"
    echo "$status" > "$out/exit-status"
  '';

  requireSuccess = pkgs: drv:
    pkgs.runCommand "${drv.name}-success" {passthru.result = drv;} ''
      status=$(cat ${drv}/exit-status)

      if [ "$status" -ne 0 ]; then
        echo "${drv.name} exited with status $status; its output is in ${drv}" >&2
        exit "$status"
      fi

      ln -s ${drv} $out
    '';
}
