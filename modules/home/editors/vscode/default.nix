# modules/home/editors/vscode/default.nix

{ config, pkgs, lib, ... }:

with lib;

let
  codeLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.editors.vscode;
  extensions = import ../common-extensions.nix { inherit pkgs cfg; };
  settings = import ../common-settings.nix { inherit lib cfg; };
  vscodeSettings = import ./settings.nix { inherit lib cfg; };
in
{
  # БЕЗ imports — вся логика здесь
  options.modules.home.editors.vscode = codeLib.mkCodeOptions "VS Code" pkgs.vscode;

  config = codeLib.mkCodeConfig {
    inherit cfg;
    extensions = extensions.list ++ (with pkgs.vscode-extensions; [
      ms-python.python
      ms-python.vscode-pylance
      charliermarsh.ruff
      ms-pyright.pyright
    ]);
    settings = settings.attrs // vscodeSettings.attrs;
  };
}