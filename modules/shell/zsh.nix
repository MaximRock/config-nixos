{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''fastfetch'';
    shellAliases = {
      nrs = "sudo nixos-rebuild-ng switch";
      nrd = "sudo nixos-rebuild dry-build";
      nrlg = "sudo nixos-rebuild list-generations";
      btw = "echo i use nixos, max";
      koda = "npx @kodadev/koda-cli@latest";
      kill-qwen = ''pkill -9 -f qwen-code; sleep 2'';
      #qc = ''nix run github:numtide/llm-agents.nix#qwen-code'';
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
