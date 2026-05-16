{ inputs }:

let
  inherit (inputs)
    nixpkgs
    nixpkgs-unstable
    home-manager
    nvf
    nur
    llm-agents
    yandex-browser
    ;

  system = "x86_64-linux";
  username = "max";

  pkgs = nixpkgs.legacyPackages.${system};

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  variables = import ../home/common/var-default.nix { inherit username; };

  nvfConfig = import ../modules/editors/configs/nvf-config { inherit pkgs; };

  overlays = [
    nur.overlays.default
    llm-agents.overlays.default
  ];

  specialArgs = {
    inherit
      inputs
      username
      variables
      unstable
      nvfConfig
      overlays
      ;
    yandexBrowserPackages = yandex-browser.packages.${system};
  };
in
{
  inherit
    system
    username
    pkgs
    unstable
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