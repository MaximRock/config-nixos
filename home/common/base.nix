# home/common/base.nix
{
  pkgs,
  lib,
  config,
  username ? "max",
  variables,
  ...
}:


{
  home.username = username;
  home.homeDirectory = variables.homeDirectory;
  home.stateVersion = variables.stateVersion;

  #nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.activation.cleanQtileCache = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    ${pkgs.findutils}/bin/find /home/${config.home.username}/.config/qtile -type d -name "__pycache__" -exec ${pkgs.coreutils}/bin/rm -rf {} + 2>/dev/null || true
  '';
}
