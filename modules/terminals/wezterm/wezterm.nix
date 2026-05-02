{
  config,
  pkgs,
  variables,
  ...
}:

let
  # weztermConfigDir = builtins.toString ./.;
  weztermConfigDir = "${variables.basePathFilesDir}/modules/terminals/wezterm";  #"${variables.homeDirectory}/${username}${variables.dotFilesDir}/modules/terminals/wezterm";
in
{
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;
  };

  xdg.configFile = {
    "wezterm/wezterm.lua".source = config.lib.file.mkOutOfStoreSymlink "${weztermConfigDir}/wezterm.lua";
    "wezterm/keys.lua".source = config.lib.file.mkOutOfStoreSymlink "${weztermConfigDir}/keys.lua";
  };
}
