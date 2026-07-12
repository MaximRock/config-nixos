# home/common/players.nix

{ ... }:

let
  modulesHome = toString ../../modules/home;
in

{
  imports = [
    "${modulesHome}/players/deadbeef"
    "${modulesHome}/players/strawberry"
  ];

  modules.home.players = {
    deadbeef.enable = true;
    strawberry.enable = false;
  };
}
