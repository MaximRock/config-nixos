{ pkgs, ... }:

{
  security.polkit.enable = true;

  services = {
    displayManager.sddm = {
      enable = true;
      theme = "elarun";
    };
    xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 35;

      windowManager.qtile = {
        enable = true;
      };
    };
  };

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

  # environment.systemPackages = with pkgs; [
  #   rofi
  #   xwallpaper
  #   lxqt.lxqt-policykit
  #   uv
  #   python314
  #   xss-lock
  #   # slock
  #   xlockmore
  # ];

  # programs.slock.enable = true;

  # services.xserver.xkb = {
  #   layout = "us,ru";
  #   variant = ",";
  #   options = "grp:ctrl_shift_toggle"; # "grp:alt_shift_toggle";
  # };
}
