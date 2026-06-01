# modules/home/editors/workspace-nix.nix

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

with lib;

let
  cfg = config.modules.home.editors.workspace-nix;
in
{
  options.modules.home.editors.workspace-nix = {
    enable = mkEnableOption "Nix/Python development workspace settings for VS Code editors";

    workspaceDir = mkOption {
      type = types.str;
      default = ".dotfiles";
      description = "Directory (relative to home) where workspace .vscode/settings.json will be created.";
    };

    flakePath = mkOption {
      type = types.str;
      default = "/home/${config.home.username}/.dotfiles";
      description = "Absolute path to the Nix flake for nixd LSP configuration.";
    };

    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "NixOS host name used by nixd to resolve configuration options.";
    };
  };

  config = mkIf cfg.enable {
    # ── Workspace settings.json для Nix-проекта ──
    # Любой VS Code-форк (VS Code, VSCodium) читает .vscode/settings.json
    # из рабочей директории как workspace settings.
    home.file."${cfg.workspaceDir}/.vscode/settings.json".text = lib.generators.toJSON { } {
      # ── Nix ──
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.semanticHighlighting.enabled" = true;
        "editor.tabSize" = 2;
      };
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
      "nix.serverSettings" = {
        nixd = {
          formatting = {
            command = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
          };
          options = {
            nixos = {
              expr = ''(builtins.getFlake "${cfg.flakePath}").nixosConfigurations.${cfg.hostName}.options'';
            };
          };
        };
      };

      # ── Python (qtile, NixOS-модули) ──
      "[python]" = {
        "editor.defaultFormatter" = "charliermarsh.ruff";
        "editor.formatOnSave" = true;
        "editor.codeActionsOnSave" = {
          "source.fixAll" = "explicit"; # ← заменяет ruff.fixAll
          "source.organizeImports" = "explicit"; # ← заменяет ruff.organizeImports
        };
      };

      "python.analysis.typeCheckingMode" = "basic";
      "python.analysis.autoImportCompletions" = true;
      "python.analysis.useImportHeuristic" = true;

      # ── Ruff (нативный сервер) ──
      "ruff.nativeServer" = "on"; # ← принудительно новый сервер
      "ruff.lint.select" = [
        "E"
        "F"
        "I"
        "N"
        "W"
        "UP"
        "B"
        "C4"
        "SIM"
      ];
      "ruff.lint.ignore" = [ "E501" ];
      "ruff.format.preview" = true;
      "ruff.lint.preview" = true;
    };

    # ── Nix/Python development tools ──
    home.packages = with pkgs; [
      nixfmt-rfc-style
      nixd
      statik
      deadnix
    ];

    # ── Flake registry ──
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
