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

      # Патч схем tool-call: современные провайдеры (OpenAI/Azure/Anthropic-роут)
      # требуют additionalProperties: false в схемах graft (см. schemas.patch).
      GRAFT_ROOT="$(${pkgs.nodejs_22}/bin/npm root -g)/@nanonets/graft"
      if [ -f "$GRAFT_ROOT/dist/ai/crux.js" ]; then
        patch -d "$GRAFT_ROOT" -p0 -N < "${./schemas.patch}" >/dev/null 2>&1 || true
        rm -f "$GRAFT_ROOT"/dist/ai/*.rej
      else
        echo "⚠️ graft не установлен — патч схем пропущен" >&2
      fi
    '';

    home.sessionPath = [ "$HOME/.npm-global/bin" ];

    home.sessionVariables = {
      GRAFT_PROVIDER = "openai";
      GRAFT_BASE_URL = "https://openrouter.ai/api/v1";
      GRAFT_MODEL = "openai/gpt-4.1-mini";
    };
  };
}
