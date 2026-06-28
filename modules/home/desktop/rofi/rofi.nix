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
      "ssh"
      "calc"
    ];
    theme = "${config.xdg.configHome}/rofi/themes/material.rasi";
    font = "JetBrainsMono Nerd Font Mono";
    plugins = with pkgs; [
      rofi-calc
      rofi-blezz
    ];
    extraConfig = {
      show-icons = true;
      # icon-theme = "Papirus-Dark";
    };
  };
}
