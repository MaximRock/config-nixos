# modules/home/opencode/default.nix

{
  config,
  lib,
  pkgs,
  variables,
  llm-agents,
  ...
}:

with lib;

let
  cfg = config.modules.home.opencode;
  base = "${variables.basePathFilesDir}/modules/home/ai-agents/opencode";
  configRoot = "${base}/config";
  projectRoot = "${base}/project";
in

{
  options.modules.home.opencode = {
    enable = mkEnableOption "opencode";
  };

  config = mkIf cfg.enable {
    home.packages = [ llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode ];

    # === sops-секреты ===
    sops = {
      defaultSopsFile = ../../../nixos/sops/secrets.yaml;
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/${variables.username}/.config/sops/age/keys.txt";
      secrets.OPENROUTER_API_KEY = { };
    };

    # === Системные конфиги (config/) → ~/.config/opencode/ ===
    xdg.configFile = {
      "opencode/opencode.jsonc".source =
        config.lib.file.mkOutOfStoreSymlink "${configRoot}/opencode.jsonc";
      "opencode/tui.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${configRoot}/tui.jsonc";
      "opencode/agents/git-commit.md".source =
        config.lib.file.mkOutOfStoreSymlink "${base}/agents/git-commit.md";
      "opencode/skills/nixos-rules/SKILL.md".source =
        config.lib.file.mkOutOfStoreSymlink "${base}/skills/nixos-rules/SKILL.md";
    };

    # === Проектные конфиги (project/) → корень репозитория ===
    home.file.".dotfiles/opencode.json".source =
      config.lib.file.mkOutOfStoreSymlink "${projectRoot}/opencode.json";

    # === Переменные окружения ===
    home.sessionVariables = {
      OPENROUTER_API_KEY = "$(cat ${config.sops.secrets.OPENROUTER_API_KEY.path})";
    };
  };
}
