# modules/common/base.nix
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # === Nix settings ===
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

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
    options = "grp:alt_shift_toggle"; # "grp:ctrl_shift_toggle";
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
