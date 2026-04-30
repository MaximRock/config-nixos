# home/common/packages.nix
{
  pkgs,
  yandexBrowserPackages,
  unstable,
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
    xfce.mousepad

    # Dev
    nodejs_22
    llm-agents.qwen-code
    # unstable.mcp-nixos

    # Browser (из внешнего флока)
    yandexBrowserPackages.yandex-browser-stable # nix flake lock --update-input yandex-browser

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
  ];
}
