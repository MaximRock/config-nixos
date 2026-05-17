{
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    # === Common modules ===
    ./modules/nixos/common/base.nix
    ./modules/nixos/common/packages.nix
    ./modules/nixos/common/user.nix

    # === Desktop (host-specific) ===
    ./modules/nixos/desktop/qtile.nix
    ./modules/nixos/desktop/thunar.nix
    ./modules/nixos/networking/throne.nix
    # ./modules/nixos/desktop/xsfce.nix
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

  # programs.throne = {
  #   enable = true;
  #   package = unstable.throne;
  #   tunMode.enable = true;
  # };

}