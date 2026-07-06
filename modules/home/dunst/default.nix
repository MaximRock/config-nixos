{ config, lib, colors, settings, ... }:

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
    services.dunst = {
      enable = true;
      settings = dunstSettings;
    };
  };
}