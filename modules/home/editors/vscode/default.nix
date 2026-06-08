# modules/home/editors/vscode/default.nix

{ config, pkgs, lib, ... }:

with lib;

let
  codeLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.editors.vscode;
  settings = import ../common-settings.nix { inherit lib cfg; };
  vscodeSettings = import ./settings.nix { inherit lib cfg; };
  commonExtensions = import ../common-extensions.nix { inherit pkgs cfg; };
  vscodeExtensions = import ./extensions.nix { inherit pkgs cfg; };
in
{
  options.modules.home.editors.vscode = codeLib.mkCodeOptions "VS Code" pkgs.vscode;

  config = codeLib.mkCodeConfig {
    inherit cfg;
    programName = "vscode";   # ← пишет в programs.vscode
    extensions = commonExtensions.list ++ vscodeExtensions.list;
    settings = settings.attrs // vscodeSettings.attrs;
  };
}




# # modules/home/editors/vscode/default.nix

# { config, pkgs, lib, ... }:

# with lib;

# let
#   codeLib = import ../lib.nix { inherit pkgs lib; };
#   cfg = config.modules.home.editors.vscode;
#   extensions = import ../common-extensions.nix { inherit pkgs cfg; };
#   settings = import ../common-settings.nix { inherit lib cfg; };
#   vscodeSettings = import ./settings.nix { inherit lib cfg; };
# in
# {
#   options.modules.home.editors.vscode = codeLib.mkCodeOptions "VS Code" pkgs.vscode;

#   config = codeLib.mkCodeConfig {
#     inherit cfg;
#     programName = "vscode";   # ← пишет в programs.vscode
#     extensions = extensions.list ++ (with pkgs.vscode-extensions; [
#       ms-python.python
#       ms-python.vscode-pylance
#       charliermarsh.ruff
#       ms-pyright.pyright
#     ]);
#     settings = settings.attrs // vscodeSettings.attrs;
#   };
# }