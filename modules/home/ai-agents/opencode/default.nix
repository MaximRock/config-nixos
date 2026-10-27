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
  uupm = "${variables.homeDirectory}/projects/ui-ux-pro-max-skill";
  uupmSkills = [
    "ui-ux-pro-max"
    "banner-design"
    "brand"
    "design-system"
    "design"
    "slides"
    "ui-styling"
  ];
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
      secrets.LLM_ROUTER_API_KEY = { };
    };

    # === Системные конфиги (config/) → ~/.config/opencode/ ===
    xdg.configFile = {
      "opencode/opencode.jsonc".source =
        config.lib.file.mkOutOfStoreSymlink "${configRoot}/opencode.jsonc";
      "opencode/tui.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${configRoot}/tui.jsonc";
      "opencode/agents/git-commit.md".source =
        config.lib.file.mkOutOfStoreSymlink "${base}/agents/git-commit.md";
      "opencode/agents/teacher.md".source =
        config.lib.file.mkOutOfStoreSymlink "${base}/agents/teacher.md";
      "opencode/skills/nixos-rules/SKILL.md".source =
        config.lib.file.mkOutOfStoreSymlink "${base}/skills/nixos-rules/SKILL.md";
      "opencode/skills/simple-explainer/SKILL.md".source =
        config.lib.file.mkOutOfStoreSymlink "${base}/skills/simple-explainer/SKILL.md";
    } // listToAttrs (map (name: {
      name = "opencode/skills/${name}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${uupm}/.claude/skills/${name}";
    }) uupmSkills);

    # === Проектные конфиги (project/) → корень репозитория ===
    home.file.".dotfiles/opencode.json".source =
      config.lib.file.mkOutOfStoreSymlink "${projectRoot}/opencode.json";

    # === Переменные окружения ===
    home.sessionVariables = {
      OPENROUTER_API_KEY = "$(cat ${config.sops.secrets.OPENROUTER_API_KEY.path})";
      LLM_ROUTER_API_KEY = "$(cat ${config.sops.secrets.LLM_ROUTER_API_KEY.path})";
    };
  };
}
