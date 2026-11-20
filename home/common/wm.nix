# home/common/wm.nix

{ qtileEnable ? false, ... }:

let
  modulesHome = toString ../../modules/home;
in

{
  imports = [
    "${modulesHome}/wm/qtile"
    "${modulesHome}/wm/niri"
  ];

  modules.home.wm.qtile.enable = qtileEnable;
  modules.home.wm.niri.enable = true;
}
