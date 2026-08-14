# modules/home/ai-agents/graft/default.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.graft;
in
{
  options.modules.home.graft = {
    enable = mkEnableOption "graft";
  };

  config = mkIf cfg.enable {
    home.activation.installGraft = ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="${pkgs.nodejs_22}/bin:$HOME/.npm-global/bin:$PATH"

      ${pkgs.nodejs_22}/bin/npm install -g @nanonets/graft@latest
    '';

    home.sessionPath = [ "$HOME/.npm-global/bin" ];

    home.sessionVariables = {
      GRAFT_PROVIDER = "openai";
      GRAFT_BASE_URL = "https://openrouter.ai/api/v1";
      GRAFT_MODEL = "anthropic/claude-sonnet-4-20250514";
    };
  };
}
