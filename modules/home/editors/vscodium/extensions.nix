# modules/home/editors/vscodium/extensions.nix

{ pkgs, cfg, ... }:

{
  list =
    with pkgs.vscode-extensions;
    [
      # -- Python --
      ms-pyright.pyright

      # -- Markdown --
      yzhang.markdown-all-in-one

      # -- Toml --
      tamasfe.even-better-toml

    ]
    ++ cfg.extraExtensions;
}
