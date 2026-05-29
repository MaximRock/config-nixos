{ pkgs, nvfConfig, ... }:

{
  imports = [
    ./configs/nvf-config/lsp/lsp-pacakgs.nix
  ];

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        options = nvfConfig.options;
        extraPlugins = {
          inc-rename = nvfConfig.plugins.incRename;
          rainbow-delimiters = nvfConfig.plugins.rainbowDelimiters;
          indent-blankline = nvfConfig.plugins.indentBlankline;
        };
        lazy = {
          enable = true;
          plugins = {
            "neo-tree.nvim" = {
              package = pkgs.vimPlugins.neo-tree-nvim;
              setupModule = "neo-tree";
              setupOpts = nvfConfig.plugins.neoTree.setupNeoTree;
              keys = nvfConfig.mappings.mappKeys;
            };
            "llama.vim" = {
              package = pkgs.vimPlugins.llama-vim;
            };
          };
        };

        lsp = nvfConfig.lsp // {
          servers = {
            lua_ls = nvfConfig.lsp.servers.lua_ls;
            nixd = nvfConfig.lsp.servers.nixd;
            jsonls = nvfConfig.lsp.servers.jsonls;
            pyright = nvfConfig.lsp.servers.pyright;
            ruff = nvfConfig.lsp.servers.ruff;
          };
        };

        visuals = {
          nvim-web-devicons = nvfConfig.plugins.newWebDevicon;
          nvim-cursorline = nvfConfig.plugins.cursorLine;
        };

        treesitter = nvfConfig.plugins.treeSitter;
        theme = nvfConfig.plugins.themeNvim;
        statusline.lualine = nvfConfig.plugins.luaLine;
        autocomplete.blink-cmp = nvfConfig.plugins.blinkCmp;
        formatter.conform-nvim = nvfConfig.plugins.conForm;
        autopairs.nvim-autopairs.enable = true;
        telescope = nvfConfig.plugins.teleScope;
        tabline.nvimBufferline = nvfConfig.plugins.bufferLine;
        diagnostics = nvfConfig.diagnostics;

        binds.whichKey = {
          enable = true;
        };

        ui.noice = nvfConfig.plugins.noIce;
        dashboard.alpha = nvfConfig.plugins.dashboardAlpha;
      };
    };
  };
}
