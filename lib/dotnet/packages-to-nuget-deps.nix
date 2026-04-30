pkgs: {
  # deadnix: skip
  name ? "project",
  lockfiles ? [],
  excludePackages ? [],
  sources ? [],
}: let
  inherit
    (pkgs.lib)
    foldl'
    attrValues
    getAttr
    attrNames
    filter
    hasAttr
    pipe
    readFile
    elem
    toLower
    optionals
    ;
  inherit (pkgs.lib.lists) concatMap unique;
  inherit (pkgs.lib.strings) fromJSON hasPrefix;

  effectiveSources =
    if sources == []
    then [{url = "https://api.nuget.org/v3-flatcontainer";}]
    else sources;

  sourceFor = pname: let
    lname = toLower pname;
    matches = s:
      (s.packagePrefixes or null)
      != null
      && s.packagePrefixes != []
      && builtins.any (p: hasPrefix (toLower p) lname) s.packagePrefixes;
    prefixed = filter matches effectiveSources;
    fallback =
      filter
      (s: (s.packagePrefixes or null) == null || s.packagePrefixes == [])
      effectiveSources;
  in
    if prefixed != []
    then builtins.head prefixed
    else if fallback != []
    then builtins.head fallback
    else throw "mkNugetDeps: no source matches package '${pname}' and no fallback source defined";

  externalDeps = lockfile: let
    allDeps' = foldl' (a: b: pkgs.lib.recursiveUpdate a b) {} (attrValues lockfile.dependencies);
    allDeps = map (n: {name = n;} // (getAttr n allDeps')) (attrNames allDeps');
  in
    filter (dep: (hasAttr "contentHash" dep) && (hasAttr "resolved" dep)) allDeps;

  getNuget = {
    name,
    resolved,
    contentHash,
    ...
  }: let
    src = sourceFor name;
    lname = toLower name;
    lver = toLower resolved;
    url = "${src.url}/${lname}/${lver}/${lname}.${lver}.nupkg";
    netrcArgs =
      optionals (src ? netrcFile && src.netrcFile != null)
      ["--netrc-file" (toString src.netrcFile)];
  in
    (pkgs.dotnetCorePackages.fetchNupkg {
      pname = name;
      version = resolved;
      hash = "sha512-${contentHash}";
    })
    .overrideAttrs (old: {
      src = pkgs.fetchurl {
        inherit (old.src) name;
        inherit url;
        hash = "sha512-${contentHash}";
        curlOptsList = netrcArgs;
        downloadToTemp = true;
        postFetch = ''
          mv $downloadedFile file.zip
          ${pkgs.zip}/bin/zip -d file.zip ".signature.p7s" || true
          mv file.zip $out
        '';
      };
    });
in
  pipe
  (concatMap
    (s:
      pipe s [
        readFile
        fromJSON
        externalDeps
      ])
    lockfiles) [
    (filter (dep: !(elem "${dep.name}-${dep.resolved}" excludePackages)))
    (map getNuget)
    unique
  ]
