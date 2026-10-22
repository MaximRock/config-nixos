{ pkgs, unstable, ... }:

{
  # Модуль programs.noctalia есть только в nixpkgs-unstable (в stable 26.05 — лишь сам пакет).
  # Импортируем модуль из уже подключённого unstable-инпута, без нового флейк-инпута.
  imports = [
    "${unstable.path}/nixos/modules/programs/wayland/noctalia.nix"
  ];

  programs.niri.enable = true;

  # Десктоп-шелл Noctalia v5 (пакет pkgs.noctalia из stable 26.05)
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  # foot — терминал для заставки-«матрицы» (и для бинда Mod+T); neo — эффект digital rain
  environment.systemPackages = [ pkgs.xwayland-satellite pkgs.foot pkgs.neo pkgs.bibata-cursors ];

  # Тема курсора мыши (пакет → /run/current-system/sw/share/icons; env — для xwayland и GTK до запуска niri)
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

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
