# modules/home/editors/vscodium/extensions.nix

{ pkgs, cfg, ... }:

{
  list =
    with pkgs.vscode-extensions;
    [
      # --Темы и иконки--
      dracula-theme.theme-dracula
      mskelton.one-dark-theme
      pkief.material-icon-theme

      # -- Python --
      ms-python.python
      ms-pyright.pyright
      charliermarsh.ruff

      # -- Nix --
      jnoortheen.nix-ide

      # -- Markdown --
      yzhang.markdown-all-in-one

      # -- Toml --
      tamasfe.even-better-toml

    ]
    ++ cfg.extraExtensions;
}
