{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.wm.niri;
  niriConfigDir = "${variables.basePathFilesDir}/modules/home/wm/niri/config";
in

{
  options.modules.home.wm.niri = {
    enable = mkEnableOption "niri Wayland compositor";
  };

  config = mkIf cfg.enable {
    xdg.configFile."niri" = {
      source = config.lib.file.mkOutOfStoreSymlink niriConfigDir;
      recursive = true;
    };

    home.packages = with pkgs; [
      waybar
      fuzzel
      grim
      slurp
      wl-clipboard
      swaybg
      swaylock
      swayidle
      mako
      wlogout
      brightnessctl
      playerctl
      pamixer
      polkit_gnome
      jq
    ];

    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "niri/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ "custom/layout" "pulseaudio" "network" "cpu" "memory" "temperature" "battery" "tray" ];

          "custom/layout" = {
            exec = "${niriConfigDir}/scripts/layout.sh";
            on-click = "niri msg action switch-layout next";
            interval = 1;
            return-type = "json";
          };

          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
            };
          };

          clock = {
            format = "{:%H:%M}";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "";
            format-icons = {
              default = [ "" "" "" ];
            };
            on-click = "pamixer -t";
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "";
            format-disconnected = "⚠";
          };

          cpu = {
            format = " {usage}%";
          };

          memory = {
            format = " {}%";
          };

          temperature = {
            format = "{temperatureC}°C";
          };

          battery = {
            format = "{capacity}% {icon}";
            format-icons = [ "" "" "" "" "" ];
          };

          tray = {
            spacing = 10;
          };
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: rgba(30, 30, 46, 0.85);
          color: #cdd6f4;
        }

        #workspaces button {
          padding: 0 5px;
          color: #585b70;
        }

        #workspaces button.active {
          color: #cdd6f4;
        }

        #workspaces button:hover {
          background: rgba(69, 71, 90, 0.5);
        }

        #custom-layout {
          color: #a6e3a1;
          padding: 0 8px;
        }

        #clock {
          color: #89b4fa;
        }

        #pulseaudio {
          color: #f5c2e7;
          padding: 0 8px;
        }

        #network {
          color: #94e2d5;
          padding: 0 8px;
        }

        #cpu, #memory, #temperature {
          color: #fab387;
          padding: 0 8px;
        }

        #battery {
          color: #a6e3a1;
          padding: 0 8px;
        }
      '';
    };
  };
}
