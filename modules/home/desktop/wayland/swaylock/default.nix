{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.swaylock;
in {
  options.modules.home.desktop.wayland.swaylock = {
    enable = mkEnableOption "swaylock screen locker";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.swaylock ];
  };
}
