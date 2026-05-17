{
  pkgs,
  inputs,
  lib,
  username,
  ...
}:

let
  vars = import ./var-editors.nix { inherit username; };

  sourceSettingsPath = "${vars.vscodeWorkspaceDir}/${vars.vscodeSettingsFile}";

  vscodeSettingsContent = lib.generators.toJSON {} {
    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
      "editor.semanticHighlighting.enabled" = true;
      "editor.tabSize" = 2;
    };
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nixd";
    "nix.serverSettings" = {
      nixd = {
        formatting = {
          command = [ "nixfmt" ];
        };
        options = {
          nixos = {
            expr = ''(builtins.getFlake "${vars.flakePath}").nixosConfigurations.${vars.hostName}.options'';
          };
        };
      };
    };
  };
in
{

  home.file.${sourceSettingsPath}.text = vscodeSettingsContent;

  home.packages = with pkgs; [
    nixfmt-rfc-style
    nixd
    statik
    deadnix
  ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
}

# { pkgs, inputs, ... }:

# {

#   home.file.".dotfiles/.vscode/settings.json".source = ./configs/vscode-nix/settings.json;

#   home.packages = with pkgs; [
#     nixfmt-rfc-style
#     nixd
#     statik
#     deadnix
#   ];

#   nix.registry.nixpkgs.flake = inputs.nixpkgs;
# }
