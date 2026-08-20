# modules/home/ai-agents/dsh/default.nix
#
# cordis-plugin-hmr требует --expose-internals в node execArgv (баг rc.7).
# Обход: после npm install заменяем симлинк bin/dsh на wrapper с флагом.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.dsh;
  dshWrapper = pkgs.writeShellScript "dsh-wrapper" ''
    exec ${pkgs.nodejs_22}/bin/node --expose-internals \
      "$HOME/.npm-global/lib/node_modules/@deepseek-ai/dsh/lib/bin.js" "$@"
  '';
in

{
  options.modules.home.dsh = {
    enable = mkEnableOption "dsh";
  };

  config = mkIf cfg.enable {
    home.activation.installDsh = ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="${pkgs.nodejs_22}/bin:$HOME/.npm-global/bin:$PATH"
      ${pkgs.nodejs_22}/bin/npm install -g @deepseek-ai/dsh@latest
      install -m 755 ${dshWrapper} "$HOME/.npm-global/bin/dsh"
    '';

    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}
