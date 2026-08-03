pkgs: {
  pname,
  version,
  site,
  conf,
  tag ? version,
  uid ? 1000,
  gid ? 1000,
  nginx ? pkgs.nginx.override {modules = [pkgs.nginxModules.brotli];},
}: let
  confDir = "/tmp/nginx";

  internalVariables = ["NGINX_MIME_TYPES" "NGINX_CONF_DIR" "NGINX_ROOT"];

  variables = let
    confFiles =
      builtins.attrNames
      (pkgs.lib.filterAttrs (_: type: type == "regular") (builtins.readDir conf));

    placeholders = file:
      builtins.concatMap (part:
        if builtins.isList part
        then part
        else [])
      (builtins.split "[$][{]([A-Z_][A-Z0-9_]*)[}]"
        (builtins.readFile (conf + "/${file}")));
  in
    pkgs.lib.subtractLists internalVariables
    (pkgs.lib.unique (builtins.concatMap placeholders confFiles));

  listenPorts = let
    lines =
      builtins.filter builtins.isString
      (builtins.split "\n" (builtins.readFile (conf + "/nginx.conf")));

    portOf = line:
      builtins.match "[[:space:]]*listen[[:space:]]+([0-9]+)[[:space:]]*;.*" line;
  in
    pkgs.lib.unique (builtins.concatMap (line: let
      match = portOf line;
    in
      if match == null
      then []
      else match)
    lines);

  root =
    pkgs.runCommand "${pname}-site" {
      nativeBuildInputs = [pkgs.brotli pkgs.zopfli];
    } ''
      cp -r ${site} $out
      chmod -R u+w $out

      find $out -type f -regex '.*\.\(html\|css\|js\|json\|svg\|txt\|xml\|wasm\)$' -print0 |
        while IFS= read -r -d "" file; do
          zopfli --i15 "$file"
          brotli --quality=11 --force --output="$file.br" "$file"
        done
    '';

  entrypoint = pkgs.writeShellApplication {
    name = "${pname}-entrypoint";

    excludeShellChecks = ["SC2016"];

    runtimeInputs = [
      pkgs.coreutils
      pkgs.gettext
      nginx
    ];

    text = ''
      export NGINX_MIME_TYPES=${nginx}/conf/mime.types
      export NGINX_CONF_DIR=${confDir}
      export NGINX_ROOT=${root}

      missing=""

      for name in ${pkgs.lib.concatMapStringsSep " " (name: "'${name}'") variables}; do
        if [ -z "''${!name-}" ]; then
          missing="''${missing}''${missing:+, }$name"
        fi
      done

      if [ -n "$missing" ]; then
        echo "Missing required configuration: $missing" >&2
        exit 1
      fi

      shellFormat=${
        pkgs.lib.escapeShellArg
        (pkgs.lib.concatMapStringsSep " " (name: "\$${name}")
          (variables ++ internalVariables))
      }

      mkdir -p ${confDir}/client-body ${confDir}/proxy

      for source in ${conf}/*; do
        rendered=$(envsubst "$shellFormat" < "$source")
        printf '%s\n' "$rendered" > ${confDir}/"$(basename "$source")"
      done

      exec nginx -c ${confDir}/nginx.conf -e /dev/stderr
    '';
  };
in
  assert pkgs.lib.assertMsg (listenPorts != []) ''
    no `listen <port>;` directive found in ${conf}/nginx.conf, so the image cannot
    declare the port it serves.
  '';
    pkgs.dockerTools.buildLayeredImage {
      name = pname;
      inherit tag;

      contents = [
        pkgs.dockerTools.fakeNss
        entrypoint
      ];

      extraCommands = ''
        mkdir -p tmp
        chmod 1777 tmp
      '';

      config = {
        User = "${toString uid}:${toString gid}";
        Entrypoint = ["${entrypoint}/bin/${pname}-entrypoint"];
        ExposedPorts = pkgs.lib.listToAttrs (map (port: {
            name = "${port}/tcp";
            value = {};
          })
          listenPorts);
        WorkingDir = "/tmp";
      };
    }
