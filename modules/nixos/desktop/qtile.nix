{ pkgs, ... }:

{
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
