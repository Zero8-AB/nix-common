pkgs: {
  self ? null,
  pname,
  version,
  src,
  subPackages,
  vendorHash ? null,
  tags ? [],
  meta ? {},
}:
pkgs.buildGoModule {
  inherit pname version src vendorHash subPackages tags;

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
