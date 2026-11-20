# home/common/base.nix
{
  pkgs,
  lib,
  config,
  username ? "max",
  variables,
  qtileEnable ? false,
  ...
}:


{
  home.username = username;
  home.homeDirectory = variables.homeDirectory;
  home.stateVersion = variables.stateVersion;

  #nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.activation = lib.optionalAttrs qtileEnable {
    cleanQtileCache = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      ${pkgs.findutils}/bin/find /home/${config.home.username}/.config/qtile -type d -name "__pycache__" -exec ${pkgs.coreutils}/bin/rm -rf {} + 2>/dev/null || true
    '';
  };
}
