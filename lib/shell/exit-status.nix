{
  recordExitStatus = command: ''
    mkdir -p "$out"

    set +e
    (
      set -e
      ${command}
    ) 2>&1 | tee "$out/log"
    status=''${PIPESTATUS[0]}
    set -e

    echo "$status" > "$out/exit-status"
  '';

  requireSuccess = pkgs: drv:
    pkgs.runCommand "${drv.name}-success" {passthru.result = drv;} ''
      status=$(cat ${drv}/exit-status)

      if [ "$status" -ne 0 ]; then
        tail -n 200 ${drv}/log >&2
        echo "${drv.name} exited with status $status; its output is in ${drv}" >&2
        exit "$status"
      fi

      ln -s ${drv} $out
    '';
}
