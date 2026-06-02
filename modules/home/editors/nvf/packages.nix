# modules/home/editors/nvf/packages.nix

{
  config,
  pkgs,
  lib,
  nvfConfig,
  ...
}:

with lib;

let
  cfg = config.modules.home.editors.nvf;
  lspCfg = nvfConfig.lsp or { };
  servers = lspCfg.servers or { };
  isServerEnabled = serverName: (servers.${serverName} or { }).enable or false;
  formatOnSave = lspCfg.formatOnSave or false;
in
{
  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      (lib.optional (isServerEnabled "lua_ls") lua-language-server)
      ++ (lib.optional (isServerEnabled "nixd") nixd)
      ++ (lib.optional (isServerEnabled "jsonls") vscode-langservers-extracted)
      ++ (lib.optional (isServerEnabled "pyright") pyright)
      ++ (lib.optional (isServerEnabled "ruff") ruff)
      ++ (lib.optional formatOnSave nixfmt)
      ++ (lib.optional formatOnSave stylua)
      ++ (lib.optional formatOnSave jq)
      ++ (lib.optional formatOnSave ruff)
      ++ [
        gcc
        ripgrep
        fd
      ]
      ++ cfg.extraPackages;
  };
}
