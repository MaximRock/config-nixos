{ pkgs, ... }:

let
  listFormatters = import ../nvf-var.nix { inherit pkgs; };
in

{
  enable = true;
  setupOpts = {
    format_after_save = {
      timeout_ms = 500;
      lsp_fallback = false;
    };
    format_on_save = {
      timeout_ms = 500;
      lsp_fallback = true;
    };
    formatters_by_ft = listFormatters;
    # {
    #   lua = [ "stylua" ];
    #   nix = [ "nixfmt" ];
    # };
  };
}
