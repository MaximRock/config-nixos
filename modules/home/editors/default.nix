# modules/home/editors/nvf/default.nix

{ ... }:

{
  imports = [
    ./nvf
    ./vscodium
    # ./vscode      # если нужен проприетарный VS Code
    # ./nvim        # если нужен чистый neovim без NVF
  ];
}