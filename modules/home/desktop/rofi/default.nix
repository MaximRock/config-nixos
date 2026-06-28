{ config, lib, pkgs, ... }:

{
  imports = [
    ./theme.nix
  ];

  xdg.configFile."rofi/themes" = {
    source = ./themes;
    recursive = true;
  };

  home.packages = with pkgs; [
    papirus-icon-theme
  ];

  programs.rofi = {
    enable = true;
    modes = [
      "drun"
      "run"
      "window"
      "ssh"
      "calc"
    ];
    font = "JetBrainsMono Nerd Font 14";
    plugins = with pkgs; [
      rofi-calc
      rofi-blezz
    ];
  };
}
