# modules/nixos/networking/happ.nix
# Host-specific wrapper around the happ-nix flake module.
{ inputs, ... }:

{
  imports = [ inputs.happ-nix.nixosModules.default ];

  services.happ = {
    enable = true;
    forceXwayland = true;
    forceSoftwareRendering = false;
    tunMode.enable = true;
    tunMode.interface = "tun0";
  };
}
