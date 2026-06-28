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
    ];
    extraConfig = {
      show-icons = true;
      icon-theme = "breeze";
      display-drun = " ";
      display-run = " ";
      display-window = " ";
      display-ssh = " ";
      display-calc = " ";
      drun-display-format = "{name}";
    };
  };
}
