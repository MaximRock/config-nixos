# modules/home/ai-agents/dsh/default.nix
#
# cordis-plugin-hmr требует --expose-internals в node execArgv (баг rc.7).
# Обход: после npm install заменяем симлинк bin/dsh на wrapper с флагом.

{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.dsh;
  dshWrapper = pkgs.writeShellScript "dsh-wrapper" ''
    exec ${pkgs.nodejs_22}/bin/node --expose-internals \
      "$HOME/.npm-global/lib/node_modules/@deepseek-ai/dsh/lib/bin.js" "$@"
  '';
  base = "${variables.basePathFilesDir}/modules/home/ai-agents/dsh";
in

{
  options.modules.home.dsh = {
    enable = mkEnableOption "dsh";
  };

  config = mkIf cfg.enable {
    home.activation.installDsh = ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="${pkgs.nodejs_22}/bin:$HOME/.npm-global/bin:$PATH"
      if [ ! -x "$HOME/.npm-global/bin/dsh" ]; then
        ${pkgs.nodejs_22}/bin/npm install -g --prefer-offline --no-audit --no-fund --loglevel=error @deepseek-ai/dsh@latest
      fi
      install -m 755 ${dshWrapper} "$HOME/.npm-global/bin/dsh"
    '';

    home.file.".dsh/settings.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${base}/settings.yaml";

    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}
