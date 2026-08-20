# modules/home/ai-agents/dsh/default.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.dsh;
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
    '';

    home.packages = [
      (pkgs.writeShellScriptBin "dsh" ''
        exec ${pkgs.nodejs_22}/bin/node --expose-internals \
          "$HOME/.npm-global/lib/node_modules/@deepseek-ai/dsh/lib/bin.js" "$@"
      '')
    ];

    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}
