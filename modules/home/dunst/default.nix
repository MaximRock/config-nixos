# modules/home/dunst/default.nix

{ config, lib, ... }:

with lib;

let
  cfg = config.modules.home.dunst;
  dunstSettings = import ./settings.nix;
in

{
  options.modules.home.dunst = {
    enable = mkEnableOption "dunst";
  };

  config = mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = dunstSettings;
    };
  };
}
