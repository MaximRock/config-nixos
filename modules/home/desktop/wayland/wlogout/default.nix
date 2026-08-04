{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.wlogout;
in {
  options.modules.home.desktop.wayland.wlogout = {
    enable = mkEnableOption "wlogout logout menu";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.wlogout ];
  };
}
