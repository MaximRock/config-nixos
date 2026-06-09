# modules/home/aider/symlinks.nix

{ config, variables, ... }:
let
  root = "${variables.basePathFilesDir}/modules/home/aider";
in
{
  home.file.".aider.conf.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${root}/aider.conf.yml";

  home.file.".aider.model.settings.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${root}/aider.model-settings.yml";

  home.file.".aider.model.metadata.json".source =
    config.lib.file.mkOutOfStoreSymlink "${root}/aider.model.metadata.json";
}
