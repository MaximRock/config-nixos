# modules/nixos/common/packages.nix

{

  pkgs,
  unstable,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # === Utils ===
    wget
    curl
    git
    vim

    uv
    python314

    # rofi

    # плеер
    pipewire
    pavucontrol
    wireplumber
    deadbeef-with-plugins
    deadbeefPlugins.mpris2

    # qtile for widgets
    lm_sensors

    # nixos
    unstable.nixos-rebuild-ng

    # анализ размера /nix/store
    nix-du
    graphviz
    ncdu

    # sops
    sops

    # для копирования
    xclip

    # costumtkinter
    fontconfig

    # === Из unstable (если нужно) ===
    # Пример: unstable.some-package
  ];
}
