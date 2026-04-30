# home.nix (в корне проекта)
{ ... }@args: import ./home/common/default.nix args

# { pkgs, yandexBrowserPackages, ... }:



# {
#   home.username = "max";
#   home.homeDirectory = "/home/max";
#   home.stateVersion = "25.11";
#   nixpkgs.config.allowUnfree = true;

#   imports = [
#     ./modules/editors/vscode.nix
#     ./modules/editors/vscode-nix.nix
#     ./modules/editors/vscode-python.nix
#     ./modules/editors/nvf-nvim.nix
#     ./modules/terminals/wezterm/wezterm.nix
#     ./modules/shell/zsh.nix
#     ./modules/desktop/gtk.nix
#     # ./modules/desktop/picom.nix
#     ./modules/desktop/rofi/rofi.nix
#     ./modules/terminals/yazi.nix
#     ./modules/apps/flameshot.nix
#     ./modules/apps/dunst.nix
#     ./modules/apps/koda.nix
#   ];

#   home.packages = with pkgs; [
#     tree
#     bat
#     btop
#     htop
#     yandexBrowserPackages.yandex-browser-stable # nix flake lock --update-input yandex-browser
#     dunst
#     nodejs_22
#     llm-agents.qwen-code
#     mcp-nixos

#   ];

#   home.sessionVariables = {
#     # EDITOR = "emacs";
#   };

#   programs.home-manager.enable = true;

# }
