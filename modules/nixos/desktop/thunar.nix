{ pkgs, ... }:

{
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [

    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.thunar-dropbox-plugin
    xfce.thunar-media-tags-plugin
    gvfs
    udisks2
  ];
}