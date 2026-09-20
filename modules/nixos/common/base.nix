# modules/common/base.nix

{

  pkgs,
  lib,
  ...
}:

{
  # === Nix settings ===
  # nix.settings.experimental-features = [
  #   "nix-command"
  #   "flakes"
  # ];
  nixpkgs.config.allowUnfree = true;

  nix = {
    optimise.automatic = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = lib.mkForce [
        # Официальный кэш — источник правды, всегда самый свежий и полный.
        # Зеркала ниже — только fallback: у них задержка репликации и таймауты,
        # каждый промах = локальная сборка из исходников с тестами.
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://comfyui.cachix.org"
        "https://nix-mirror.freetls.fastly.net"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
        # "https://cuda-maintainers.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };

  # === Network (без hostname — он host-specific) ===
  networking.networkmanager.enable = true;

  # === Locale & Timezone ===
  time.timeZone = "Europe/Moscow";
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us,ru";
    variant = ",";
    # options = "grp:alt_shift_toggle"; # "grp:ctrl_shift_toggle";
  };

  # === Sound ===
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
    pulse.enable = true;
  };
  boot.kernelParams = [ "snd-intel-dspcfg.dsp_driver=1" ];

  # === Printing ===
  services.printing.enable = true;

  # === Fonts ===
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.droid-sans-mono
    noto-fonts
    noto-fonts-color-emoji
  ];

  # === Shell globally ===
  programs.zsh = {
    enable = true;
    # interactiveShellInit = ''
    #   fastfetch
    # '';
  };
  programs.dconf.enable = true;
  # programs.firefox.enable = true;

  # === State version ===
  system.stateVersion = "25.11";
}
