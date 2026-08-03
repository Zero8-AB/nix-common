pkgs: {
  fonts,
  prefer ? {},
}: let
  alias = family: preferred: ''
    <alias>
        <family>${family}</family>
        <prefer><family>${preferred}</family></prefer>
      </alias>'';

  aliases = pkgs.lib.concatStringsSep "\n\n  " (pkgs.lib.mapAttrsToList alias prefer);
in
  pkgs.writeText "fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <include>${pkgs.makeFontsConf {fontDirectories = fonts;}}</include>

      ${aliases}
    </fontconfig>
  ''
