{
  nginx,
  lib,
  withRealIp ? false,
}: let
  excludedFlags = [
    "--with-http_ssl_module"
    "--with-http_v2_module"
    "--with-http_v3_module"
    "--with-http_xslt_module"
    "--with-http_dav_module"
    "--with-http_flv_module"
    "--with-http_mp4_module"
    "--with-http_addition_module"
    "--with-http_sub_module"
    "--with-http_random_index_module"
    "--with-http_secure_link_module"
    "--with-http_degradation_module"
    "--with-http_auth_request_module"
    "--with-http_stub_status_module"
    "--with-http_gunzip_module"
    "--with-file-aio"
  ]
  ++ lib.optional (!withRealIp) "--with-http_realip_module";

  includedFlags = [
    "--with-http_gzip_static_module"
    "--with-pcre-jit"
    "--with-threads"
  ];
in
  (nginx.override {
    modules = [];
    withPerl = false;
    withStream = false;
    withMail = false;
    withDebug = false;
    withKTLS = false;
  })
  .overrideAttrs (old: {
    pname = "nginx-minimal";
    configureFlags =
      builtins.filter (f: !(builtins.elem f excludedFlags)) old.configureFlags
      ++ includedFlags;
    meta =
      old.meta
      // {
        description = "nginx with minimal modules for static SPA serving";
      };
  })
