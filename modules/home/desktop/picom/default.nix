# modules/home/desktop/picom/default.nix

{ config, lib, ... }:

with lib;

let
  cfg = config.modules.home.picom;
in

{
  options.modules.home.picom = {
    enable = mkEnableOption "picom";
  };

  config = mkIf cfg.enable {

    services.picom = {
      enable = true;
      backend = "glx";
      activeOpacity = 1;
      inactiveOpacity = 1;
      fade = true;
      fadeSteps = [
        0.04
        0.04
      ];
      settings = {
        opacity-rule = [
          "100:class_g = 'rofi'"
        ];
        corner-radius = 12;
        corner-radius-rules = [
          "0:window_type = 'notification'"
        ];
      };
    };
  };
}
