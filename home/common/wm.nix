# home/common/wm.nix

{ ... }:

let
  modulesHome = toString ../../modules/home;
in

{
  imports = [
    "${modulesHome}/wm/qtile"
    "${modulesHome}/wm/niri"
  ];

  modules.home.wm.qtile.enable = true;
  modules.home.wm.niri.enable = true;
}
