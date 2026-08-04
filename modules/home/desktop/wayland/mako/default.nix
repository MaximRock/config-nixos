{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.mako;
in {
  options.modules.home.desktop.wayland.mako = {
    enable = mkEnableOption "mako notification daemon";

    colors = mkOption {
      type = types.nullOr (types.attrsOf types.str);
      default = null;
      description = "Color palette for mako notifications";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.mako ];

    xdg.configFile."mako/config" = mkIf (cfg.colors != null) {
      text = ''
        font=JetBrainsMono Nerd Font 11
        background-color=${cfg.colors.background}
        text-color=${cfg.colors.foreground}
        border-color=${cfg.colors.primary}
        progress-color=${cfg.colors.success}
        border-size=2
        default-timeout=5000
        max-icon-size=48
      '';
    };
  };
}
