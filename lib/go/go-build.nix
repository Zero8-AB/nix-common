pkgs: {
  pname,
  version,
  src,
  subPackages,
  self,
  vendorHash ? null,
  meta ? {},
}:
pkgs.buildGoModule {
  inherit pname version src vendorHash subPackages;

  meta = with pkgs.lib;
    {
      mainProgram = pname;
    }
    // meta;

  ldflags = [
    "-s -w"
    "-X main.version=${self.shortRev or "dev"}"
  ];

  preBuild = "export CGO_ENABLED=0";
}
