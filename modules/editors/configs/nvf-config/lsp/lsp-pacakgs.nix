{
  config,
  pkgs,
  lib,
  ...
}:

let
  nvfConfig = config.programs.nvf.settings.vim.lsp;
  isServerEnabled = serverName: nvfConfig.servers.${serverName}.enable or false;
in

{
  home.packages =
    with pkgs;
    # LSP серверы
    (lib.optional (isServerEnabled "lua_ls") lua-language-server)
    ++ (lib.optional (isServerEnabled "nixd") nixd)
    ++ (lib.optional (isServerEnabled "jsonls") vscode-langservers-extracted)
    ++ (lib.optional (isServerEnabled "pyright") pyright)
    ++ (lib .optional (isServerEnabled "ruff") ruff)
    ++

      # formatters
      (lib.optional (nvfConfig.formatOnSave or false) nixfmt-rfc-style)
    ++ (lib.optional (nvfConfig.formatOnSave or false) stylua)
    ++ (lib.optional (nvfConfig.formatOnSave or false) jq)
    ++ (lib.optional (nvfConfig.formatOnSave or false) ruff)
    ++

      [
        # for treesitter
        gcc
        # for telescope
        ripgrep
        fd
        # for json
        jq
      ];
}
