# modules/desktop/qtile/default.nix
{
  config,
  variables,
  username ? "max",
  lib,
  ...
}:

let
  qtileConfigDir = "${variables.homeDirectory}/${username}${variables.dotFilesDir}/modules/desktop/qtile/config"; # путь к директории с config.py и модулями
in
{

  xdg.configFile."qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink qtileConfigDir;
    recursive = true;
  };

  home.sessionVariables.PYTHONPATH = "${config.xdg.configHome}/qtile:$HOME/.local/lib/python3.13/site-packages";
}
