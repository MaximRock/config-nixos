# home/common/wm.nix

{ ... }:

let
  modulesHome = toString ../../modules/home;
in

{
  imports = [
    "${modulesHome}/wm/qtile"
  ];

  modules.home.wm.qtile.enable = true;
}
