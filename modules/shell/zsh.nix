{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = "fastfetch";
    shellAliases = {
      nrs = "sudo nixos-rebuild-ng switch";
      nrd = "sudo nixos-rebuild-ng dry-build";
      nrlg = "sudo nixos-rebuild-ng list-generations";
      nix-test = "nix flake check && sudo nixos-rebuild-ng test";
      btw = "echo i use nixos, max";
      koda = "npx @kodadev/koda-cli@latest";
      kill-qwen = "pkill -9 -f qwen-code; sleep 2";
      #qc = ''nix run github:numtide/llm-agents.nix#qwen-code'';
      nix-viz = ''
        nix-du -g -s 500MB /nix/store | \
          dot -Tsvg -Goverlap=prism -Gsplines=true -o nix-store.svg && \
          xdg-open nix-store.svg
      '';
      nix-profile-viz = ''
        nix-du -g --root ~/.nix-profile -s 100MB | \
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
