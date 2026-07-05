# home/common/default.nix
{ ... }:

{
  # === Базовые модули ===
  imports = [
    ./base.nix
    ./packages.nix
    ./user.nix
    ./editors.nix
    ./terminals.nix

    # === Ваши существующие модули из ./modules/ ===
    # Editors
    ../../modules/home/editors/vscodium
    ../../modules/home/editors/vscodium/workspace-nix.nix
    ../../modules/home/editors

    # Shell
    ../../modules/home/shell/zsh

    # Git
    ../../modules/home/git

    # Qtile
    ../../modules/home/desktop/qtile/default.nix
    ../../modules/home/power-menu
    ../../modules/home/qtile-help

    # Desktop
    ../../modules/home/desktop/gtk
    ../../modules/home/desktop/picom
    ../../modules/home/desktop/rofi

    # Apps
    ../../modules/home/flameshot
    ../../modules/home/dunst

    # Browsers
    ../../modules/home/browsers/firefox/default.nix

    # AI and agents
    ../../modules/home/aider
    ../../modules/home/opencode
    ../../modules/home/rime-mcp
    ../../modules/home/koda
  ];

  modules.home = {

    # Browsers
    browsers.firefox = {
      nighttab = true;
      chromeCss = true;
    };
    # Qtile modules
    power-menu.enable = true;
    qtile-help.enable = true;

    git.enable = true;

    # Apps
    flameshot.enable = true;
    dunst.enable = true;

    # AI and Agents
    koda.enable = true;
    aider.enable = true;
    opencode.enable = true;
    rime-mcp.enable = true;

    # Desktop
    gtk.enable = true;
    picom.enable = true;

    # Shell
    zsh.enable = true;
  };
}
