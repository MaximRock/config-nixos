# modules/home/aider/default.nix

{
  config,
  lib,
  pkgs,
  variables,
  ...
}:

with lib;

let
  cfg = config.modules.home.aider;
  root = "${variables.basePathFilesDir}/modules/home/ai-agents/aider";
  secretName = "OPENROUTER_API_KEY";
  secretPath = "/run/secrets/${secretName}";
in

{
  options.modules.home.aider = {
    enable = mkEnableOption "aider";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "aider" ''
        if [ -f "${secretPath}" ]; then
          export OPENROUTER_API_KEY=$(cat "${secretPath}")
          export AIDER_OPENROUTER_API_KEY="$OPENROUTER_API_KEY"
        else
          echo "⚠️  Secret ${secretPath} not found. Run 'sudo nixos-rebuild switch' and relogin." >&2
        fi
        exec ${pkgs.aider-chat}/bin/aider "$@"
      '')
    ];

    home.file.".aider.conf.yml".source = config.lib.file.mkOutOfStoreSymlink "${root}/aider.conf.yml";
    home.file.".aider.model.settings.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${root}/aider.model-settings.yml";
    home.file.".aider.model.metadata.json".source =
      config.lib.file.mkOutOfStoreSymlink "${root}/aider.model.metadata.json";
  };
}
