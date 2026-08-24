# modules/home/ai-agents/ponytail/default.nix
#
# Установка ponytail — lazy senior dev mode для AI-агентов.
# Добавляет правила минимального кода в AGENTS.md (общий знаменатель для OpenCode, DSH, Cursor и др.)
# и устанавливает npm-пакет для OpenCode plugin (команды /ponytail lite|full|ultra|off).

{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.ponytail;
  configDir = "${variables.basePathFilesDir}/modules/home/ai-agents/ponytail";
in

{
  options.modules.home.ponytail = {
    enable = mkEnableOption "ponytail (lazy senior dev mode)";
  };

  config = mkIf cfg.enable {
    home.activation.installPonytail = ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="${pkgs.nodejs_22}/bin:$HOME/.npm-global/bin:$PATH"
      if [ ! -x "$HOME/.npm-global/bin/ponytail" ] && [ ! -d "$HOME/.npm-global/lib/node_modules/@dietrichgebert/ponytail" ]; then
        echo "Installing ponytail from npm..."
        ${pkgs.nodejs_22}/bin/npm install -g --prefer-offline --no-audit --no-fund --loglevel=error @dietrichgebert/ponytail@latest
      else
        echo "ponytail already installed, checking for updates..."
        ${pkgs.nodejs_22}/bin/npm update -g --prefer-offline --no-audit --no-fund --loglevel=error @dietrichgebert/ponytail
      fi
    '';

    # Опциональный конфиг ponytail — можно переопределить level по умолчанию
    home.file.".config/ponytail/config.json".source =
      config.lib.file.mkOutOfStoreSymlink "${configDir}/config.json";

    # Добавляем npm global bin в PATH (если ещё не добавлен другим модулем)
    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}