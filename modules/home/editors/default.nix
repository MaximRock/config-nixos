# modules/home/editors/nvf/default.nix

{ ... }:

{
  imports = [
    ./nvf
    ./vscodium
    ./vscode      # если нужен проприетарный VS Code
    ./workspace-nix.nix
    # ./nvim        # если нужен чистый neovim без NVF
  ];
}