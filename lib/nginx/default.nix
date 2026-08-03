{
  minimal = import ./minimal-nginx.nix;
  mkStaticSite = import ./static-site.nix;
}
