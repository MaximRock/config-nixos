# home/common/packages.nix
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # Utils
    tree
    bat
    btop
    htop

    # Apps
    dunst
    fastfetch
    mousepad

    # LLm
    nodejs_22
    llm-agents.reasonix
    python313Packages.huggingface-hub
    # aider-chat
    # unstable.mcp-nixos

    # Browser (из внешнего флока)
    pkgs.yandex-browser.yandex-browser-stable # nix flake lock --update-input yandex-browser

    # terminal
    yazi
    tmux

    # превью
    chafa
    ffmpegthumbnailer
    poppler-utils
    mediainfo

    # архивы
    p7zip
    unzip
    zip

    # ускорение поиска
    fd
    ripgrep
    fzf

    # плеер
    deadbeef
    strawberry

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
  ];
}
