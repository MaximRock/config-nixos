# modules/home/desktop/gtk/default.nix
#
# GTK-тема, иконки и курсоры.
# Имена тем берутся из центрального settings.json (секция `gtk`),
# пакеты резолвятся здесь — они специфичны для Nixpkgs.
#
{ config, lib, pkgs, colors, settings, ... }:

with lib;

let
  cfg = config.modules.home.gtk;
  g = settings.gtk;

  gtkThemePackage = {
    "Orchis-Dark" = pkgs.orchis-theme;
  }.${g.theme} or pkgs.orchis-theme;

  iconThemePackage = {
    "Papirus-Dark" = pkgs.papirus-icon-theme;
  }.${g.icon_theme} or pkgs.papirus-icon-theme;

  cursorThemePackage = {
    "Bibata-Modern-Ice" = pkgs.bibata-cursors;
  }.${g.cursor_theme} or pkgs.bibata-cursors;
in

{
  options.modules.home.gtk = {
    enable = mkEnableOption "gtk";
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;

      theme = {
        name = g.theme;
        package = gtkThemePackage;
      };

      iconTheme = {
        name = g.icon_theme;
        package = iconThemePackage;
      };

      cursorTheme = {
        name = g.cursor_theme;
        package = cursorThemePackage;
        size = g.cursor_size;
      };

      gtk4.theme = config.gtk.theme;
      gtk4.extraConfig = {
        gtk-theme-name = g.theme;
        gtk-icon-theme-name = g.icon_theme;
        gtk-cursor-theme-name = g.cursor_theme;
        gtk-cursor-theme-size = g.cursor_size;
      };
    };
  };
}
