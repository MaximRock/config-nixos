# modules/home/players/strawberry/default.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.players.strawberry;
in

{
  options.modules.home.players.strawberry = {
    enable = mkEnableOption "Strawberry";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.strawberry ];
  };
}
