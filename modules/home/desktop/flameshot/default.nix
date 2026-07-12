# modules/home/desktop/flameshot/default.nix

{ config, lib, ... }:

with lib;

let
    cfg = config.modules.home.flameshot;
in

{
  options.modules.home.flameshot = {
    enable = mkEnableOption "flameshot";
  };

  config = mkIf cfg.enable {
    services.flameshot.enable = true;
  };
}

