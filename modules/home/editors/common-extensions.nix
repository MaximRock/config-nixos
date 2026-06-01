# modules/home/editors/common-extensions.nix

{ pkgs, cfg }:

{
  list = with pkgs.vscode-extensions; [
    # ── Темы и иконки ──
    dracula-theme.theme-dracula
    mskelton.one-dark-theme
    pkief.material-icon-theme

    # ── Nix ──
    jnoortheen.nix-ide

  ] ++ cfg.extraExtensions;
}