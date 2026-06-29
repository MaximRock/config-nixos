{ pkgs, ... }:

{
  imports = [
    ./theme.nix
  ];

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
