# modules/home/players/deadbeef/default.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.players.deadbeef;
in

{
  options.modules.home.players.deadbeef = {
    enable = mkEnableOption "DeadBeeF";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.deadbeef ];
  };
}
