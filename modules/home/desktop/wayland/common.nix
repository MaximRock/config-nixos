{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.common;
in {
  options.modules.home.desktop.wayland.common = {
    enable = mkEnableOption "common Wayland utilities";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      brightnessctl
      playerctl
      pamixer
      polkit_gnome
      jq
    ];
  };
}
