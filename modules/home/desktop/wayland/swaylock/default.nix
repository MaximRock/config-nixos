{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.swaylock;
in {
  options.modules.home.desktop.wayland.swaylock = {
    enable = mkEnableOption "swaylock screen locker";

    colors = mkOption {
      type = types.nullOr (types.attrsOf types.str);
      default = null;
      description = "Color palette for swaylock";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.swaylock ];

    xdg.configFile."swaylock/config" = mkIf (cfg.colors != null) {
      text = ''
        font=JetBrainsMono Nerd Font
        font-size=14

        ring-color=${cfg.colors.primary}
        key-hl-color=${cfg.colors.success}
        line-color=${cfg.colors.background}
        inside-color=${cfg.colors.surface}
        separator-color=${cfg.colors.primary}
        text-color=${cfg.colors.foreground}
        text-ver-color=${cfg.colors.foreground}
        wrong-color=${cfg.colors.error}
        bs-hl-color=${cfg.colors.error}
      '';
    };
  };
}
