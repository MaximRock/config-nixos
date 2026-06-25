

{ config, pkgs, ... }:

let
  mcp-helper = pkgs.callPackage ../../modules/home/nixos-helper {};
in
{
  environment.systemPackages = [
    mcp-helper
  ];
}