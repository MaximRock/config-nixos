{ pkgs, ... }:

{
  programs.niri.enable = true;

  security.polkit.enable = true;

  systemd.user.services.polkit-agent = {
    description = "Polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    configPackages = [ pkgs.niri ];
  };

  systemd.user.services.niri.serviceConfig.Environment = [
    "NIXOS_OZONE_WL=1"
    "XDG_CURRENT_DESKTOP=niri"
  ];
}
