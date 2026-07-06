# modules/home/dunst/default.nix
#
# Подключает dunst через Home Manager.
# Настройки читает из ./settings.nix, который получает цвета и параметры
# из центрального SSOT (settings.json + lib/theme.nix → specialArgs).
#
{ config, lib, pkgs, colors, settings, ... }:

with lib;

let
  cfg = config.modules.home.dunst;
  dunstSettings = import ./settings.nix { inherit colors settings; };
in

{
  options.modules.home.dunst = {
    enable = mkEnableOption "dunst";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.libnotify ];

    services.dunst = {
      enable = true;
      settings = dunstSettings;
    };
  };
}