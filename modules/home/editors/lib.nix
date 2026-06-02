# modules/home/editors/lib.nix

{ pkgs, lib }:

with lib;

{
  mkCodeOptions = name: defaultPackage: {
    enable = mkEnableOption "${name} editor configuration";
    package = mkOption {
      type = types.package;
      default = defaultPackage;
      description = "${name} package to use.";
    };
    extraExtensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
    extraSettings = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  mkCodeConfig = { cfg, programName ? "vscode", extensions, settings }:
    mkIf cfg.enable {
      programs.${programName} = {
        enable = true;
        package = cfg.package;
        profiles.default = {
          extensions = extensions;
          userSettings = settings // cfg.extraSettings;
        };
      };
    };
}