# home/common/default.nix
{ ... }:

{
  # === Базовые модули ===
  imports = [
    ./base.nix
    ./packages.nix
    ./user.nix
    ./editors.nix
    ./browsers.nix
    ./power-menu.nix
    ./qtile-help.nix
    ./rime-mcp.nix

    # === Ваши существующие модули из ./modules/ ===
    # Editors
    ../../modules/home/editors/vscodium
    ../../modules/home/editors/vscodium/workspace-nix.nix
    ../../modules/home/editors
    # ../../modules/home/editors/vscode.nix
    # ../../modules/home/editors/vscode-nix.nix
    # ../../modules/home/editors/vscode-python.nix
    # ../../modules/home/editors/nvf-nvim.nix

    # Terminals
    ../../modules/home/terminals/wezterm/wezterm.nix
    ../../modules/home/terminals/yazi.nix
    ../../modules/home/terminals/fastfetch/fastfetch.nix

    # Shell
    ../../modules/home/shell/zsh.nix

    # Desktop
    # qtile config
    ../../modules/home/desktop/qtile/default.nix
    ../../modules/home/desktop/gtk.nix
    ../../modules/home/desktop/picom.nix
    ../../modules/home/desktop/rofi

    # Apps
    ../../modules/home/apps/flameshot.nix
    ../../modules/home/apps/dunst.nix
    ../../modules/home/apps/koda.nix
    ../../modules/home/apps/git.nix

    # Browsers
    ../../modules/home/browsers/firefox/default.nix

    # aider
    ../../modules/home/aider/default.nix

    # opencode
    ../../modules/home/opencode/default.nix
  ];

}
