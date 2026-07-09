{ config, pkgs, lib, appColors, ... }:

let
  terminalLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.terminals.fastfetch;

  logoFile = ./logo3.png;

  fastfetchConfig = {
    logo = {
      type = "kitty";
      source = "$HOME/.config/fastfetch/logo.png";
      width = 30;
      height = 15;
      padding = {
        top = 1;
        bottom = 1;
        left = 2;
        right = 4;
      };
    };

    color = {
      keys = appColors.fastfetch.primary;
      title = appColors.fastfetch.secondary;
      subtitle = appColors.fastfetch.inactive;
      bar = appColors.fastfetch.selected;
      separator = appColors.fastfetch.separator_color;
    };

    modules = [
      { type = "title"; keyColor = appColors.fastfetch.secondary; }
      "separator"
      { type = "os"; key = " "; keyColor = appColors.fastfetch.primary; }
      { type = "host"; key = "󰍹 "; keyColor = appColors.fastfetch.secondary; }
      { type = "kernel"; key = " "; keyColor = appColors.fastfetch.tertiary; }
      { type = "uptime"; key = "󰔟 "; keyColor = appColors.fastfetch.success; }
      { type = "shell"; key = " "; keyColor = appColors.fastfetch.secondary; }
      { type = "display"; key = "󰍹 "; keyColor = appColors.fastfetch.primary; }
      { type = "de"; key = " "; keyColor = appColors.fastfetch.tertiary; }
      { type = "theme"; key = " "; keyColor = appColors.fastfetch.warning; }
      { type = "terminal"; key = " "; keyColor = appColors.fastfetch.success; }
      { type = "cpu"; key = " "; keyColor = appColors.fastfetch.error; }
      { type = "gpu"; key = "󰢮 "; keyColor = appColors.fastfetch.success; }
      { type = "memory"; key = " "; keyColor = appColors.fastfetch.primary; }
      { type = "disk"; key = "󰋊 "; keyColor = appColors.fastfetch.accent; }
      "colors"
    ];
  };
in

{
  options.modules.home.terminals.fastfetch =
    terminalLib.mkTerminalOptions "fastfetch" pkgs.fastfetch;

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.fastfetch.enable = false;

    xdg.configFile."fastfetch/logo.png".source = logoFile;

    xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON fastfetchConfig;
  };
}
