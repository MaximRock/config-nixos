# Интеграция Home Manager в NixOS.
# Все specialArgs автоматически доступны и в HM-модулях.
{ config, pkgs, lib, specialArgs, inputs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    sharedModules = [
      inputs.nvf.homeManagerModules.default
    ];

    users.${specialArgs.username} = import ../../home/common/default.nix;

    extraSpecialArgs = specialArgs;
  };
}