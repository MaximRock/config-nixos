{ config, pkgs, lib, ... }:

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
      keys = "#b4befe";
      title = "#cba6f7";
      subtitle = "#9399b2";
      bar = "#585b70";
      separator = "#6c7086";
    };

    modules = [
      { type = "title"; keyColor = "#cba6f7"; }
      "separator"
      { type = "os"; key = " "; keyColor = "#89b4fa"; }
      { type = "host"; key = "󰍹 "; keyColor = "#cba6f7"; }
      { type = "kernel"; key = " "; keyColor = "#94e2d5"; }
      { type = "uptime"; key = "󰔟 "; keyColor = "#a6e3a1"; }
      { type = "shell"; key = " "; keyColor = "#cba6f7"; }
      { type = "display"; key = "󰍹 "; keyColor = "#89b4fa"; }
      { type = "de"; key = " "; keyColor = "#94e2d5"; }
      { type = "theme"; key = " "; keyColor = "#f9e2af"; }
      { type = "terminal"; key = " "; keyColor = "#a6e3a1"; }
      { type = "cpu"; key = " "; keyColor = "#f38ba8"; }
      { type = "gpu"; key = "󰢮 "; keyColor = "#a6e3a1"; }
      { type = "memory"; key = " "; keyColor = "#89b4fa"; }
      { type = "disk"; key = "󰋊 "; keyColor = "#fab387"; }
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
