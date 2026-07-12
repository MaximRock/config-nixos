# home/common/default.nix
{ ... }:

let
  modulesHome = toString ../../modules/home;
in

{
  # === Базовые модули ===
  imports = [
    ./base.nix
    ./packages.nix
    ./user.nix
    ./editors.nix
    ./terminals.nix
    ./ai-agents.nix

    # === Ваши существующие модули из ./modules/ ===
    # Editors
    "${modulesHome}/editors/vscodium"
    "${modulesHome}/editors/vscodium/workspace-nix.nix"
    "${modulesHome}/editors"

    # Shell
    "${modulesHome}/shell/zsh"

    # Git
    "${modulesHome}/git"

    # Qtile
    "${modulesHome}/desktop/qtile/default.nix"
    "${modulesHome}/power-menu"
    "${modulesHome}/qtile-help"

    # Desktop
    "${modulesHome}/desktop/gtk"
    "${modulesHome}/desktop/picom"
    "${modulesHome}/desktop/rofi"

    # Apps
    "${modulesHome}/flameshot"
    "${modulesHome}/dunst"

    # Browsers
    "${modulesHome}/browsers/firefox/default.nix"

    # AI and agents
#    "${modulesHome}/aider"
#    "${modulesHome}/opencode"
#    "${modulesHome}/rime-mcp"
#    "${modulesHome}/koda"
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
#    koda.enable = true;
#    aider.enable = true;
#    opencode.enable = true;
#    rime-mcp.enable = true;

    # Desktop
    gtk.enable = true;
    picom.enable = true;

    # Shell
    zsh.enable = true;
  };
}
