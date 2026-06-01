# modules/home/editors/nvf/editor.nix

{ config, pkgs, lib, nvfConfig, ... }:

with lib;

let
  cfg = config.modules.home.editors.nvf;
  
  # Безопасный доступ к вложенным полям
  plugins = nvfConfig.plugins or {};
  lspCfg = nvfConfig.lsp or {};
  mappings = nvfConfig.mappings or {};
  diagnostics = nvfConfig.diagnostics or {};
  options = nvfConfig.options or {};
in
{
  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      settings = {
        vim = {
          # ── Options ──
          options = options;

          # ── Extra Plugins ──
          extraPlugins = {
            inc-rename = plugins.incRename or {};
            rainbow-delimiters = plugins.rainbowDelimiters or {};
            indent-blankline = plugins.indentBlankline or {};
          } // cfg.extraPlugins;

          # ── Lazy Plugins ──
          # mappings.mappKeys используется ТОЛЬКО здесь, не на верхнем уровне vim!
          lazy = {
            enable = true;
            plugins = {
              "neo-tree.nvim" = {
                package = pkgs.vimPlugins.neo-tree-nvim;
                setupModule = "neo-tree";
                setupOpts = (plugins.neoTree or {}).setupNeoTree or {};
                keys = mappings.mappKeys or [];
              };
              "llama.vim" = {
                package = pkgs.vimPlugins.llama-vim;
              };
            };
          };

          # ── LSP ──
          lsp = lspCfg // {
            servers = {
              lua_ls = (lspCfg.servers.lua_ls or {}) // { enable = true; };
              nixd = (lspCfg.servers.nixd or {}) // { enable = true; };
              jsonls = (lspCfg.servers.jsonls or {}) // { enable = true; };
              pyright = (lspCfg.servers.pyright or {}) // { enable = true; };
              ruff = (lspCfg.servers.ruff or {}) // { enable = true; };
            };
          };

          # ── Остальные секции ──
          visuals = {
            nvim-web-devicons = plugins.newWebDevicon or {};
            nvim-cursorline = plugins.cursorLine or {};
          };
          treesitter = plugins.treeSitter or {};
          theme = plugins.themeNvim or {};
          statusline.lualine = plugins.luaLine or {};
          autocomplete.blink-cmp = plugins.blinkCmp or {};
          formatter.conform-nvim = plugins.conForm or {};
          autopairs.nvim-autopairs.enable = true;
          telescope = plugins.teleScope or {};
          tabline.nvimBufferline = plugins.bufferLine or {};
          diagnostics = diagnostics;
          binds.whichKey = { enable = true; };
          ui.noice = plugins.noIce or {};
          dashboard.alpha = plugins.dashboardAlpha or {};

        } // cfg.extraSettings;
      };
    };
  };
}