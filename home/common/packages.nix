# home/common/packages.nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Utils
    tree
    bat
    btop
    htop

    # Apps
    mousepad

    # LLm
    nodejs_22
    python313Packages.huggingface-hub
    # aider-chat-with-help
    # unstable.mcp-nixos

    # Browser (из внешнего флока)
    pkgs.yandex-browser.yandex-browser-stable # nix flake lock --update-input yandex-browser

    # terminal
    # yazi
    tmux

    xwallpaper

    lxqt.lxqt-policykit

    xss-lock
    # slock
    xlockmore

    obsidian

    # Изображения
    upscayl
    flameshot

    telegram-desktop

    zoom-us

  ];
}
