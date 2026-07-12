{ config, lib, pkgs, appColors, ... }:

with lib;

let
  cfg = config.modules.home.dunst;
  dunstSettings = import ./settings.nix { colors = appColors.dunst; };
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
