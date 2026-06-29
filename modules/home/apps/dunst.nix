# modules/home/apps/dunst.nix

{
  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      font = "JetBrainsMonoNL Nerd Font 10";
      follow = "mouse";
      width = 300;
      height = 100;
      origin = "top-right";
      offset = "10x10";
      notification_limit = 5;
      transparency = 10;
      frame_color = "#89b4fa";
      separator_color = "frame";
    };

    urgency_low = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      timeout = 5;
    };

    urgency_normal = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      timeout = 10;
    };

    urgency_critical = {
      background = "#f38ba8";
      foreground = "#1e1e2e";
      timeout = 0;
    };
  };
}
