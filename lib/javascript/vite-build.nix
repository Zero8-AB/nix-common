pkgs: {
  pname,
  version,
  src,
  nodeModules,
  command ? "vite build",
  nativeBuildInputs ? [],
  derivationArgs ? {},
}:
import ./check.nix pkgs {
  inherit pname version src nodeModules command nativeBuildInputs;

  name = "dist";

  installPhase = ''
    runHook preInstall

    mkdir -p $out $sourcemaps

    cp -r dist/. $out/
    chmod -R u+w $out

    find $out -name '*.map' -print0 |
      while IFS= read -r -d "" map; do
        relative="''${map#$out/}"
        mkdir -p "$sourcemaps/$(dirname "$relative")"
        mv "$map" "$sourcemaps/$relative"
      done

    runHook postInstall
  '';

  derivationArgs = {outputs = ["out" "sourcemaps"];} // derivationArgs;
}
