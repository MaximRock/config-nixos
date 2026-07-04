# modules/home/opencode/default.nix

{ config, lib, variables, ... }:

with lib;

let
  cfg = config.modules.home.opencode;
  root = "${variables.basePathFilesDir}/modules/home/opencode";
in

{
  options.modules.home.opencode = {
    enable = mkEnableOption "opencode";
  };

  config = mkIf cfg.enable {
    # === sops-секреты ===
    sops = {
      defaultSopsFile = ../../nixos/sops/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/${variables.username}/.config/sops/age/keys.txt";
      secrets.OPENROUTER_API_KEY = { };
    };

    # === Симлинки на конфиги в ~/.config/opencode/ ===
    xdg.configFile = {
      "opencode/opencode.jsonc".source =
        config.lib.file.mkOutOfStoreSymlink "${root}/opencode.jsonc";
      "opencode/tui.jsonc".source =
        config.lib.file.mkOutOfStoreSymlink "${root}/tui.jsonc";
      "opencode/agents/git-commit.md".source =
        config.lib.file.mkOutOfStoreSymlink "${root}/git-commit.md";
      "opencode/skills/nixos-rules/SKILL.md".source =
        config.lib.file.mkOutOfStoreSymlink "${root}/skills/nixos-rules/SKILL.md";
    };

    # === Симлинк на проектный opencode.json в корне репозитория ===
    home.file.".dotfiles/opencode.json".source =
      config.lib.file.mkOutOfStoreSymlink "${root}/opencode.json";

    # === Переменные окружения ===
    home.sessionVariables = {
      OPENROUTER_API_KEY = "$(cat ${config.sops.secrets.OPENROUTER_API_KEY.path})";
    };
  };
}
