# modules/home/editors/nvf/default.nix

{ lib, ... }:

with lib;

#let
#  cfg = config.modules.home.editors.nvf;
#in
{
  imports = [
    ./editor.nix
    ./packages.nix
  ];

  options.modules.home.editors.nvf = {
    enable = mkEnableOption "Neovim via NVF (Nix Vim Framework)";

    extraPlugins = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra lazy plugins to merge with nvfConfig";
    };

    extraSettings = mkOption {
      type = types.attrs;
      default = { };
      description = "Extra vim settings to merge with nvfConfig";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages (LSP servers, formatters, tools)";
    };
  };
}
