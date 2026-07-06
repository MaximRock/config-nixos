# modules/home/desktop/rofi/default.nix
#
# Лаунчер rofi.
# Шрифт и modes из центрального settings.json (секция `rofi`).
# Цвета темы — из activeTheme (lib/theme.nix → specialArgs).
#
{ pkgs, settings, ... }:

{
  imports = [
    ./theme.nix
  ];

  home.packages = with pkgs; [
    papirus-icon-theme
  ];

  programs.rofi = {
    enable = true;
    modes = settings.rofi.modes;
    font = "${settings.rofi.font} ${toString settings.rofi.font_size}";
    plugins = with pkgs; [
      rofi-calc
      rofi-blezz
    ];
  };
}
