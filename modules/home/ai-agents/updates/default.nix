# modules/home/ai-agents/updates.nix
#
# Фоновое обновление глобальных npm-CLI (dsh/graft/koda) до @latest.
# Не блокирует загрузку: запускается после network-online и раз в сутки.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.npmUpdate;

  # Копия wrapper'а из dsh (нужен для пере-применения после обновления dsh).
  dshWrapper = pkgs.writeShellScript "dsh-wrapper" ''
    exec ${pkgs.nodejs_22}/bin/node --expose-internals \
      "$HOME/.npm-global/lib/node_modules/@deepseek-ai/dsh/lib/bin.js" "$@"
  '';

  updateScript = pkgs.writeShellScript "npm-global-update" ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="${pkgs.nodejs_22}/bin:$HOME/.npm-global/bin:$PATH"

    for p in @deepseek-ai/dsh@latest @nanonets/graft@latest @kodadev/koda-cli@latest; do
      ${pkgs.nodejs_22}/bin/npm install -g --no-audit --no-fund --loglevel=error "$p" || true
    done

    install -m 755 ${dshWrapper} "$HOME/.npm-global/bin/dsh"
  '';
in
{
  options.modules.home.npmUpdate = {
    enable = mkEnableOption "background updates of global npm CLI tools (dsh/graft/koda)";
  };

  config = mkIf cfg.enable {
    systemd.user.services.npmGlobalUpdate = {
      Unit = {
        Description = "Update global npm CLI tools (dsh/graft/koda)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        Environment = [ "NPM_CONFIG_PREFIX=%h/.npm-global" ];
        ExecStart = updateScript;
      };
    };

    systemd.user.timers.npmGlobalUpdate = {
      Unit.Description = "Daily update of global npm CLI tools";
      Timer = {
        OnBootSec = "5min";
        OnUnitActiveSec = "1d";
        Unit = "npmGlobalUpdate.service";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
