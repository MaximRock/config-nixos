# modules/home/desktop/picom.nix

{
  services.picom = {
    enable = true;
    backend = "glx";
    activeOpacity = 1;
    inactiveOpacity = 1;
    fade = true;
    fadeSteps = [
      0.04
      0.04
    ];
    settings = {
      opacity-rule = [
        "100:class_g = 'rofi'"
      ];
      corner-radius = 12;
    };
  };
}
