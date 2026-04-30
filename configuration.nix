{
  pkgs,
  unstable,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    # === Common modules ===
    ./modules/common/base.nix
    ./modules/common/packages.nix
    ./modules/common/user.nix

    # === Desktop (host-specific) ===
    ./modules/desktop/qtile.nix
    ./modules/desktop/thunar.nix
    # ./modules/desktop/xsfce.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };
  
  networking.hostName = "nixos";

  programs.throne = {
    enable = true;
    package = unstable.throne;
    tunMode.enable = true;
  };

}