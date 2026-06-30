# modules/home/editors/common-extensions.nix

{ pkgs, cfg }:

{
  list =
    with pkgs.vscode-extensions;
    [
      # ── Темы и иконки ──
      dracula-theme.theme-dracula
      mskelton.one-dark-theme
      charliermarsh.ruff
      pkief.material-icon-theme

      # ── Nix ──
      jnoortheen.nix-ide

      # --Astro and Tailwind --
      astro-build.astro-vscode
      bradlc.vscode-tailwindcss
      esbenp.prettier-vscode

      # -- DirEnv
      mkhl.direnv

    ]
    ++ cfg.extraExtensions;
}
