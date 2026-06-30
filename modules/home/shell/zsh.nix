# modules/home/shell/zsh.nix

{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      fastfetch
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
      #qc = ''nix run github:numtide/llm-agents.nix#qwen-code'';
      nix-viz = ''
        nix-du -s 500MB | \
          dot -Tsvg -Goverlap=prism -Gsplines=true -o nix-store.svg && \
          xdg-open nix-store.svg
      '';
      # Какие пакеты, установленные с помощью nix-env, занимают больше всего места?
      nix-profile-viz = ''
        nix-du --root ~/.nix-profile -s 100MB | \
          dot -Tsvg -Goverlap=prism -o profile.svg && \
          xdg-open profile.svg
      '';
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "python"
        "docker"
      ];
      theme = "bira";
    };
  };
}
