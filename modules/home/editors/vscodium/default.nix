# modules/home/editors/vscodium/default.nix

{ config, pkgs, lib, ... }:

with lib;

let
  codeLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.editors.vscodium;
  extensions = import ../common-extensions.nix { inherit pkgs cfg; };
  settings = import ../common-settings.nix { inherit lib cfg; };
  vscodeSettings = import ./settings.nix { inherit lib cfg; };
in
{
  options.modules.home.editors.vscodium = codeLib.mkCodeOptions "VSCodium" pkgs.vscodium;

  config = codeLib.mkCodeConfig {
    inherit cfg;
    programName = "vscodium";   # ← пишет в programs.vscodium
    extensions = extensions.list ++ (with pkgs.vscode-extensions; [
      ms-python.python
      ms-python.vscode-pylance
      charliermarsh.ruff
      ms-pyright.pyright
    ]);
    settings = settings.attrs // vscodeSettings.attrs;
  };
}