{ config, pkgs, ... }:

{
  # -- VSCodium --
  modules.home.editors.vscodium = {
    enable = true;
    extraExtensions = with pkgs.vscode-extensions; [
      # -- Радужные отступы --
      oderwat.indent-rainbow
    ];
    extraSettings = {
    };
  };

  # ── Neovim (если используете через модуль) ──
  # modules.home.editors.nvim.enable = true;
}
