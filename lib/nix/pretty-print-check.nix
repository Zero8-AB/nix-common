{lib}: {
  title,
  command,
  logfile ? null,
  showCommand ? true,
  exitOnFailure ? true 
}: let
  safeTitle =
    lib.replaceStrings
    [" " "/" ":" "'" "\""]
    ["-" "-" "-" "" ""]
    (lib.toLower title);

  logfileAssignment =
    if logfile == null
    then ''logfile="$TMPDIR/check-log-${safeTitle}.log"''
    else ''logfile=${lib.escapeShellArg logfile}'';
in ''
  ${logfileAssignment}

  set +e
  {
    ${command}
  } > $logfile 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    red="$(printf '\033[31m')"
    yellow="$(printf '\033[33m')"
    bold="$(printf '\033[1m')"
    dim="$(printf '\033[2m')"
    reset="$(printf '\033[0m')"

    echo >&2
    echo >&2 "''${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${reset}"
    echo >&2 "''${bold}''${red}${title}''${reset}"
    echo >&2 "''${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${reset}"
    echo >&2
    ${lib.optionalString showCommand ''
    echo >&2 "''${yellow}Command:''${reset} ''${dim}${command}''${reset}"
    echo >&2
  ''}
    cat $logfile >&2
    echo >&2
    echo >&2 "''${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${reset}"
    echo >&2

    ${if exitOnFailure then ''
      exit "$status"
    '' else ''
      pretty_check_failed=1
    ''}
  fi
''
