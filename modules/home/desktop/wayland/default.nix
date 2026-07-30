{ config, lib, ... }:

with lib;

{
  imports = [
    ./common.nix
    ./fuzzel
    ./mako
    ./swaybg
    ./swaylock
    ./swayidle
    ./wlogout
    ./waybar
  ];
}
