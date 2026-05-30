# modules/home/editors/vscodium/editor.nix

{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.home.editors.vscodium;
  extensions = import ./extensions.nix { inherit pkgs cfg; };
  settings   = import ./settings.nix   { inherit lib cfg; };
in
{
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