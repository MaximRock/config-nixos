# home/common/edirors.nix

{ pkgs, ... }:

{
  # ── VSCodium ──
  modules.home.editors.vscodium = {
    enable = true;
    extraExtensions = with pkgs.vscode-extensions; [
      oderwat.indent-rainbow
    ];
    extraSettings = {
      "indentRainbow.indicatorStyle" = "light";
      "indentRainbow.lightIndicatorStyleLineWidth" = 1;
      "indentRainbow.colors" = [
        "rgba(255,255,64,0.3)"
        "rgba(127,255,127,0.3)"
        "rgba(255,127,255,0.3)"
        "rgba(79,236,236,0.3)"
      ];
    };
  };

  # ── Nix workspace settings (общий для VS Code и VSCodium) ──
  modules.home.editors.workspace-nix = {
    enable = true;
    workspaceDir = ".dotfiles";
    flakePath = "/home/max/.dotfiles";
    hostName = "nixos";
  };

  # ── VS Code (проприетарный) ──
  modules.home.editors.vscode = {
    enable = false;
    extraExtensions = with pkgs.vscode-extensions; [
      ms-python.vscode-pylance
    ];
  };

  # ── Neovim (NVF) ──
  modules.home.editors.nvf = {
    enable = true;
  };
}
