# modules/home/git/default.nix
#
# Git-конфиг.
# user.name и user.email из центрального settings.json (секция `git`).
#
{ config, lib, settings, ... }:

with lib;

let
  cfg = config.modules.home.git;
  g = settings.git;
in {
  options.modules.home.git = {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user.name = g.user_name;
        user.email = g.user_email;
        init.defaultBranch = g.default_branch;
      };
    };
  };
}
