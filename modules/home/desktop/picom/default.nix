# modules/home/desktop/picom/default.nix
#
# Композитор окон picom.
# Настройки берутся из центрального settings.json (секция `picom`).
# corner-radius-rules для notification-окон остаётся здесь — это фикс
# совместимости picom+dunst, а не пользовательская настройка.
#
{ config, lib, colors, settings, ... }:

with lib;

let
  cfg = config.modules.home.picom;
  p = settings.picom;
in

{
  options.modules.home.picom = {
    enable = mkEnableOption "picom";
  };

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      backend = p.backend;
      activeOpacity = p.active_opacity;
      inactiveOpacity = p.inactive_opacity;
      fade = p.fade;
      fadeSteps = p.fade_steps;
      settings = {
        opacity-rule = p.opacity_rules;
        corner-radius = p.corner_radius;
        corner-radius-rules = [
          "0:window_type = 'notification'"
        ];
      };
    };
  };
}
