# modules/home/ai-agents/nix-repo-navigator/default.nix

{
  config,
  lib,
  pkgs,
  nix-repo-navigator,
  variables,
  ...
}:

with lib;

let
  cfg = config.modules.home.nix-repo-navigator;
  package = nix-repo-navigator.packages.${pkgs.stdenv.hostPlatform.system}.default;
in

{
  options.modules.home.nix-repo-navigator = {
    enable = mkEnableOption "nix-repo-navigator";
  };

  config = mkIf cfg.enable {
    home.packages = [ package ];

    systemd.user.services.nix-repo-navigator-watch = {
      Unit.Description = "nix-repo-navigator graph watcher";
      Service = {
        ExecStart = "${package}/bin/nix-repo-navigator watch ${variables.basePathFilesDir} --plugins python --parse-unreferenced --exclude 11";
        Environment = [ "PYTHONPATH=" ];
        Restart = "on-failure";
        RestartSec = "3s";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
