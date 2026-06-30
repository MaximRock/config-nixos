{ config, pkgs, lib, ... }:

let
  terminalLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.terminals.wezterm;
  configDir = builtins.toString ./.;
in

{
  options.modules.home.terminals.wezterm =
    terminalLib.mkTerminalOptions "WezTerm" pkgs.wezterm;

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      package = cfg.package;
    };

    xdg.configFile = {
      "wezterm/wezterm.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${configDir}/wezterm.lua";
      "wezterm/keys.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${configDir}/keys.lua";
    };
  };
}
