# modules/home/qtile-help/default.nix

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.home.qtile-help;
in
{
  options.modules.home.qtile-help = {
    enable = lib.mkEnableOption "qtile help";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.callPackage ./package.nix { }) ];
  };
}
