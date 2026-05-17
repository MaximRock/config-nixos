{pkgs, ... }:

{
  home.activation.installKoda = ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"

    if [ ! -f "$HOME/.npm-global/bin/koda" ]; then
      ${pkgs.nodejs_22}/bin/npm install -g @kodadev/koda-cli@latest
    fi
  '';

  home.sessionPath = [ "$HOME/.npm-global/bin" ];
}
