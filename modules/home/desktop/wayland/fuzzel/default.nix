{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.desktop.wayland.fuzzel;
in {
  options.modules.home.desktop.wayland.fuzzel = {
    enable = mkEnableOption "fuzzel application launcher";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.fuzzel ];
  };
}
