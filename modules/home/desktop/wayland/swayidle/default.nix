{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.swayidle;
in {
  options.modules.home.desktop.wayland.swayidle = {
    enable = mkEnableOption "swayidle idle management daemon";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.swayidle ];
  };
}
