{ pkgs, ... }:

{
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [

    thunar
    thunar-archive-plugin
    thunar-volman
    thunar-dropbox-plugin
    thunar-media-tags-plugin
    gvfs
    udisks2
  ];
}
