# modules/home/editors/lib.nix

{ pkgs, lib }:

with lib;

{
  # ── Общие опции для VS Code / VSCodium ──
  mkCodeOptions = name: defaultPackage: {
    enable = mkEnableOption "${name} editor configuration";

    package = mkOption {
      type = types.package;
      default = defaultPackage;
      defaultText = literalExpression "pkgs.${name}";
      description = "${name} package to use.";
    };

    extraExtensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional extensions to install.";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra user settings to merge with defaults.";
    };
  };

  # ── Общий config builder ──
  mkCodeConfig = { cfg, extensions, settings }:
    mkIf cfg.enable {
      programs.vscode = {
        enable = true;
        package = cfg.package;
        profiles.default = {
          extensions = extensions;
          userSettings = settings // cfg.extraSettings;
        };
      };
    };
}