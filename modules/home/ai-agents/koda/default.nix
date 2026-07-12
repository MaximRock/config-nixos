# modules/home/koda/default.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.koda;
in

{
  options.modules.home.koda = {
    enable = mkEnableOption "koda";
  };

  config = mkIf cfg.enable {
    home.activation.installKoda = ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"

      if [ ! -f "$HOME/.npm-global/bin/koda" ]; then
        ${pkgs.nodejs_22}/bin/npm install -g @kodadev/koda-cli@latest
      fi
    '';

    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}
