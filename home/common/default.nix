# home/common/default.nix
{ pkgs, lib, username ? "max", yandexBrowserPackages, unstable, nvfConfig, inputs, ... }:

{
  # === Базовые модули ===
  imports = [
    ./base.nix
    ./packages.nix
    ./user.nix

    # === Ваши существующие модули из ./modules/ ===
    # Editors
    ../../modules/editors/vscode.nix
    ../../modules/editors/vscode-nix.nix
    # ../../modules/editors/vscode-python.nix
    ../../modules/editors/nvf-nvim.nix

    # Terminals
    ../../modules/terminals/wezterm/wezterm.nix
    ../../modules/terminals/yazi.nix
    ../../modules/terminals/fastfetch/fastfetch.nix

    # Shell
    ../../modules/shell/zsh.nix

    # Desktop
    # qtile config
    ../../modules/desktop/qtile/default.nix
    ../../modules/desktop/gtk.nix
    ../../modules/desktop/picom.nix
    ../../modules/desktop/rofi/rofi.nix

    # Apps
    ../../modules/apps/flameshot.nix
    ../../modules/apps/dunst.nix
    ../../modules/apps/koda.nix
    ../../modules/apps/git.nix
    ../../modules/browsers/firefox.nix
  ];

}