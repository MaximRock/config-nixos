

{ config, pkgs, ... }:

let
  mcp-helper = pkgs.callPackage ../../modules/home/ai-agents/nixos-helper {};
in
{
  environment.systemPackages = [
    mcp-helper
  ];
}
