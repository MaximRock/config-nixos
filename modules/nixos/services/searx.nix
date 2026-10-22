{ config, lib, ... }:

let
  cfg = config.modules.nixos.services.searx;
in
{
  options.modules.nixos.services.searx = {
    enable = lib.mkEnableOption "local SearXNG instance";
  };

  config = lib.mkIf cfg.enable {
    services.searx = {
      enable = true;
      openFirewall = false;
      environmentFile = config.sops.secrets.SEARXNG_SECRET.path;

      settings = {
        general.instance_name = "curio";

        server = {
          bind_address = "127.0.0.1";
          port = 8888;
          base_url = "http://127.0.0.1:8888/";
          secret_key = "$SEARXNG_SECRET";
          limiter = false;
        };

        engines = [
          {
            name = "bing";
            disabled = false;
          }
          {
            name = "brave";
            disabled = true;
          }
          {
            name = "duckduckgo";
            disabled = true;
          }
          {
            name = "startpage";
            disabled = true;
          }
        ];

        search.formats = [
          "html"
          "json"
        ];
      };
    };
  };
}
