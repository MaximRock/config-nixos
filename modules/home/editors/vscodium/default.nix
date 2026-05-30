# modules/home/editors/vscodium/default.nix

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.home.editors.vscodium;
  extensions = import ./extensions.nix { inherit pkgs cfg; };
  settings   = import ./settings.nix   { inherit lib cfg; };
in
{
  options.modules.home.editors.vscodium = {
    enable = mkEnableOption "VSCodium editor";

    package = mkOption {
      type = types.package;
      default = pkgs.vscodium;
    };

    extraExtensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional extensions to install";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra settings to merge with defaults";
    };
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = cfg.package;
      profiles.default = {
        extensions = extensions.list;
        userSettings = settings.attrs; 
      };
    };
  };
}
