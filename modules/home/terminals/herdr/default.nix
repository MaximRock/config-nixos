{
  config,
  lib,
  unstable,
  variables,
  ...
}:

with lib;

let
  cfg = config.modules.home.terminals.herdr;
in

{
  options.modules.home.terminals.herdr = {
    enable = mkEnableOption "herdr";
  };

  config = mkIf cfg.enable {
    home.packages = [ unstable.herdr ];

    xdg.configFile."herdr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${variables.basePathFilesDir}/modules/home/terminals/herdr/config.toml";
  };
}
