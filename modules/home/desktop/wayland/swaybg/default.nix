{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.swaybg;
in {
  options.modules.home.desktop.wayland.swaybg = {
    enable = mkEnableOption "swaybg wallpaper daemon";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.swaybg ];
  };
}
