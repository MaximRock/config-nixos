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
      # -- indent-rainbow --
      # Цветные линии
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

  # ── Neovim (если используете через модуль) ──
  # modules.home.editors.nvim.enable = true;
}
