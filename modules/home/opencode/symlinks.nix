# modules/home/opencode/synlinks.nix

{ config, variables, ... }:
let
  root = "${variables.basePathFilesDir}/modules/home/opencode";
in
{
  # Конфигурация sops-nix на уровне Home Manager
  sops = {
    defaultSopsFile = ../../nixos/sops/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${variables.username}/.config/sops/age/keys.txt";
    secrets.OPENROUTER_API_KEY = { };
  };

  xdg.configFile = {
    "opencode/opencode.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${root}/opencode.jsonc";
    "opencode/tui.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${root}/tui.jsonc";
    "opencode/agents/git-commit.md".source =
      config.lib.file.mkOutOfStoreSymlink "${root}/git-commit.md";

  };

  home.sessionVariables = {
    OPENROUTER_API_KEY = "$(cat ${config.sops.secrets.OPENROUTER_API_KEY.path})";
  };
}
