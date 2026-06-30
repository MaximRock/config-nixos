# modules/home/editors/config/nvf-config/lsp/default.nix

{ ... }:

{
  enable = true;
  formatOnSave = true;
  inlayHints.enable = true;
  lspconfig.enable = true;
  lspkind.enable = true;
  trouble.enable = true;

  servers = {
    lua_ls = {
      enable = true;
      cmd = [ "lua-language-server" ];
      filetypes = [ "lua" ];
      root_markers = [
        ".luarc.json"
        ".luarc.jsonc"
        ".luacheckrc"
        ".stylua.toml"
        "stylua.toml"
        "selene.toml"
        "selene.yml"
        ".git"
      ];

      settings = {
        Lua = {
          # Указание версии Lua (LuaJIT используется в Neovim)
          runtime = {
            version = "LuaJIT";
          };
          diagnostics = {
            # Глобальные переменные, которые LSP должен распознавать
            # 'vim' - глобальная переменная Neovim API
            globals = [ "vim" ];
          };
          workspace = {
            # Игнорировать сторонние библиотеки (уменьшает диагностику)
            checkThirdParty = false;
          };
          telemetry = {
            # Отключить телеметрию
            enable = false;
          };
        };
      };
    };

    nixd = {
      enable = true;
      cmd = [ "nixd" ];
      filetypes = [ "nix" ];
      root_markers = [
        "flake.nix"
        ".git"
      ];

      settings = {
        nixd = {
          nixpkgs = {
            expr = "import <nixpkgs> { }";
          };
          formatting = {
            command = [ "nixfmt" ];
          };
          options = {
            nixos = {
              expr = "(builtins.getFlake \"/home/max/.dotfiles\").nixosConfigurations.nixos.options";
            };
            home_manager = {
              expr = "(builtins.getFlake \"/home/max/.dotfiles\").homeConfigurations.max.options";
            };
          };
        };
      };
    };

    jsonls = {
      enable = true;
      cmd = [
        "vscode-json-language-server"
        "--stdio"
      ];
      filetypes = [
        "json"
        "jsonc"
      ];
      init-options = {
        provideFormatter = true;
      };
      root_markers = [ ".git" ];
    };
    pyright = {
      cmd = [
        "pyright-langserver"
        "--stdio"
      ];
      filetypes = [ "python" ];
      root_markers = [
        "pyrightconfig.json"
        "pyproject.toml"
        "setup.py"
        "setup.cfg"
        "requirements.txt"
        "Pipfile"
        ".git"
      ];
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "off";
            autoImportCompletions = true;
            autoSearchPaths = true;
            useLibraryCodeForTypes = true;

            # Подсказки типов
            inlayHints = {
              variableTypes = true;
              functionReturnTypes = true;
              callArgumentNames = true;
            };
          };
        };
      };
      # settings = {
      #   python = {
      #     analysis = {
      #       autoSearchPaths = true;
      #       diagnosticMode = "openFilesOnly";
      #       useLibraryCodeForTypes = true;
      #     };
      #   };
      # };
    };
    ruff = {
      cmd = [
        "ruff"
        "server"
      ];
      filetypes = [ "python" ];
      root_markers = [
        "pyproject.toml"
        "ruff.toml"
        ".ruff.toml"
        ".git"
      ];
      settings = {
        lineLength = 88;
        configuration = "pyproject.toml";
      };
    };
  };
}
