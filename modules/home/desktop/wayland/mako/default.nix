{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.mako;
in {
  options.modules.home.desktop.wayland.mako = {
    enable = mkEnableOption "mako notification daemon";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.mako ];
  };
}
