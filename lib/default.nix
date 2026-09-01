{ inputs }:

let
  inherit (inputs)
    nixpkgs
    home-manager
    sops-nix
    nvf
    wezterm
    llm-agents
    herdr
    nix-repo-navigator
    ;

  system = "x86_64-linux";
  username = "max";

  pkgs = (nixpkgs.legacyPackages.${system}).extend (nixpkgs.lib.composeManyExtensions overlays);
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

  overlays = import ./overlays.nix { inherit inputs; };

  variables = import ../home/common/var-default.nix { inherit username; };

  nvfConfig = import ../modules/home/editors/configs/nvf-config { inherit pkgs; };

  inherit (import ./qtile/theme.nix { inherit (pkgs) lib; })
    themeName
    themePresets
    activeTheme
    colors
    appThemeNames
    appColors
    appActiveThemes
    ;

  specialArgs = {
    inherit
      inputs
      system
      username
      variables
      nvfConfig
      nvf
      wezterm
      llm-agents
      herdr
      nix-repo-navigator
      overlays
      unstable
      themeName
      themePresets
      activeTheme
      colors
      appThemeNames
      appColors
      appActiveThemes
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
    colors
    appThemeNames
    appColors
    appActiveThemes
    ;

  mkNixosConfiguration =
    { hostName, hostPath }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = specialArgs // {
        inherit hostName;
      };
      modules = [
        sops-nix.nixosModules.sops
        (hostPath + /default.nix)
        ../modules/nixos
        home-manager.nixosModules.home-manager
        ../modules/nixos/home-manager.nix
      ];
    };
}
