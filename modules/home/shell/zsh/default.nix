{ config, lib, ... }:

with lib;

let
  cfg = config.modules.home.zsh;
in

{
  options.modules.home.zsh = {
    enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        # fastfetch только в первом шелле сессии; маркер живёт в /run/user и чистится logind'ом
        ff_once="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/fastfetch-session-shown"
        if [[ ! -e "$ff_once" ]]; then
          fastfetch
          touch "$ff_once" 2>/dev/null
        fi
        eval "$(direnv hook zsh)"
      '';
      shellAliases = {
        nrs = "sudo nixos-rebuild switch";
        nrd = "sudo nixos-rebuild dry-build";
        nrlg = "sudo nixos-rebuild list-generations";
        nix-test = "nix flake check && sudo nixos-rebuild test";
        btw = "echo i use nixos, max";
        koda = "npx @kodadev/koda-cli@latest";
        kill-qwen = "pkill -9 -f qwen-code; sleep 2";
        nix-viz = ''
          nix-du -s 500MB | \
            dot -Tsvg -Goverlap=prism -Gsplines=true -o nix-store.svg && \
            xdg-open nix-store.svg
        '';
        nix-profile-viz = ''
          nix-du --root ~/.nix-profile -s 100MB | \
            dot -Tsvg -Goverlap=prism -o profile.svg && \
            xdg-open profile.svg
        '';
      };
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "python" "docker" ];
        theme = "bira";
      };
    };
  };
}
