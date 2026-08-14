# modules/home/ai-agents/open-design/default.nix

{ config, lib, ... }:

with lib;

let
  cfg = config.modules.home.open-design;
in

{
  options.modules.home.open-design = {
    enable = mkEnableOption "Open Design — daemon (od) + веб-интерфейс";
  };

  config = mkIf cfg.enable {
    services.open-design = {
      enable = true;
      autoStart = true;
      webFrontend.enable = true;
    };
  };
}
