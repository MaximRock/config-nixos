# modules/home/rime-mcp/default.nix

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.home.rime-mcp;
in
{
  options.modules.home.rime-mcp = {
    enable = lib.mkEnableOption "rime MCP server (Nix tooling for LLM agents)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.rime ];
  };
}
