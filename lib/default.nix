{ inputs }:

let
  inherit (inputs)
    nixpkgs
    home-manager
    nvf
    ;

  system = "x86_64-linux";
  username = "max";

  pkgs = nixpkgs.legacyPackages.${system};

  overlays = import ./overlays.nix { inherit inputs; };

  variables = import ../home/common/var-default.nix { inherit username; };

  nvfConfig = import ../modules/home/editors/configs/nvf-config { inherit pkgs; };

  specialArgs = {
    inherit
      inputs
      username
      variables
      nvfConfig
      overlays
      ;
  };
in
{
  inherit
    system
    username
    pkgs
    variables
    nvfConfig
    specialArgs
    overlays
    ;

  mkNixosConfiguration = { hostName, hostPath }:
    nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        (hostPath + /default.nix)
        ../modules/nixos
        home-manager.nixosModules.home-manager
        ../modules/nixos/home-manager.nix
      ];
    };
}