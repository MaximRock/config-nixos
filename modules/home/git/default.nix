# modules/home/git/default.nix

{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.home.git;
in
{
  options.modules.home.git = {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user.name = "MaximRock";
        user.email = "maxrockvardill@gmail.com";
        init.defaultBranch = "main";
      };
    };
  };
}

