{ pkgs, qtileEnable ? false, ... }:

let
  importIfExists =
    path: default: if builtins.pathExists path then import path { inherit pkgs qtileEnable; } else default;
in

{
  mappings = importIfExists ./mappings.nix { };
  lsp = importIfExists ./lsp { };
  plugins = importIfExists ./plugins { };
  options = importIfExists ./options.nix { };
  diagnostics = importIfExists ./diagnostics.nix { };
}
