{ pkgs, config, ... }:

{
  xdg.configFile."rofi/themes" = {
    source = ./themes;
    recursive = true;
  };

  programs.rofi = {
    enable = true;
    modes = [
      "drun"
      "run"
      "window"
      "emoji"
      "ssh"
      "calc"
    ];
    theme = "${config.xdg.configHome}/rofi/themes/material.rasi";
    font = "JetBrainsMono Nerd Font 14";
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus";
    };
  };
}
