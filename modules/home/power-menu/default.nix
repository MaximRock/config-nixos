# modules/home/power_menu/default.nix

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.power-menu;
in
{
  options.modules.power-menu = {
    enable = lib.mkEnableOption "qtile power menu";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
