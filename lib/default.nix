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

  # ── Theme: читаем THEME_COLOR из constants.py и JSON пресеты ──
  constantsContent = builtins.readFile ../modules/home/desktop/qtile/config/constants.py;
  themeMatch = builtins.match
    ".*\n?THEME_COLOR = \"([^\"]+)\".*" constantsContent;
  themeName = if themeMatch == null
    then builtins.throw "Cannot parse THEME_COLOR from constants.py"
    else builtins.head themeMatch;

  presetsDir = ../modules/home/desktop/qtile/config/config_qtile/theme/presets;
  readPreset = name: builtins.elemAt (builtins.fromJSON (builtins.readFile "${presetsDir}/${name}.json")) 0;

  themePresets = {
    catppuccin = readPreset "catppuccin";
    gruvbox = readPreset "gruvbox";
    tokyonight = readPreset "tokyonight";
  };

  activeTheme = themePresets.${themeName};

  specialArgs = {
    inherit
      inputs
      username
      variables
      nvfConfig
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
      inherit specialArgs;
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
