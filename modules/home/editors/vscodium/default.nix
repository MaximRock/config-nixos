# modules/home/editors/vscodium/default.nix
{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.modules.home.editors.vscodium;
in
{
  imports = [
    ./editor.nix
    ./workspace-nix.nix
  ];

  options.modules.home.editors.vscodium = {
    enable = mkEnableOption "VSCodium editor with Nix workspace support";

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

    nixDev = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Nix development workspace settings";
    };
  };
}