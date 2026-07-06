# modules/home/desktop/gtk/default.nix

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.home.gtk;
in

{
  options.modules.home.gtk = {
    enable = mkEnableOption "gtk";
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;

      theme = {
        name = "Orchis-Dark";
        package = pkgs.orchis-theme;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      cursorTheme = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;
      };

      gtk4.theme = config.gtk.theme;
      gtk4.extraConfig = {
        gtk-theme-name = "Orchis-Dark";
        gtk-icon-theme-name = "Papirus-Dark";
        gtk-cursor-theme-name = "Bibata-Modern-Ice";
        gtk-cursor-theme-size = 24;
      };
    };
  };
}
