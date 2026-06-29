{ inputs }:

let
  inherit (inputs)
    nixpkgs
    home-manager
    sops-nix
    nvf
    ;

  system = "x86_64-linux";
  username = "max";

  pkgs = nixpkgs.legacyPackages.${system};
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

  overlays = import ./overlays.nix { inherit inputs; };

  variables = import ../home/common/var-default.nix { inherit username; };

  nvfConfig = import ../modules/home/editors/configs/nvf-config { inherit pkgs; };

  inherit (import ./theme.nix) themeName themePresets activeTheme;

  specialArgs = {
    inherit
      inputs
      username
      variables
      nvfConfig
      nvf
      overlays
      unstable
      themeName
      themePresets
      activeTheme
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
    unstable
    themeName
    themePresets
    activeTheme
    ;

  mkNixosConfiguration =
    { hostName, hostPath }:
    nixpkgs.lib.nixosSystem {
      specialArgs = specialArgs // { inherit hostName; };
      modules = [
        { nixpkgs.hostPlatform = system; }
        sops-nix.nixosModules.sops
        (hostPath + /default.nix)
        ../modules/nixos
        home-manager.nixosModules.home-manager
        ../modules/nixos/home-manager.nix
      ];
    };
}
