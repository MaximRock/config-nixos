# modules/home/desktop/gtk/default.nix

{ config, lib, pkgs, ... }:

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
        name = "orchis-dark";
        package = pkgs.orchis-theme;
      };

      iconTheme = {
        name = "papirus-dark";
        package = pkgs.papirus-icon-theme;
      };

      cursorTheme = {
        name = "bibata-modern-ice";
        package = pkgs.bibata-cursors;
        size = 24;
      };

      gtk4.extraConfig = {
        gtk-theme-name = "orchis-dark";
        gtk-icon-theme-name = "papirus-dark";
        gtk-cursor-theme-name = "bibata-modern-ice";
        gtk-cursor-theme-size = 24;
      };
    };
  };
}
