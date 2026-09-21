# modules/nixos/common/default.nix
# Агрегатор общих NixOS-модулей (по аналогии с home/common/default.nix)
# Здесь же включается/выключается LLM-модуль (llama.cpp, ROCm).
{ config, lib, ... }:

{
  imports = [
    ./base.nix
    ./packages.nix
    ./user.nix
    ../llm
  ];

  options.modules.nixos.llm.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Включить LLM-модуль (llama.cpp с ROCm)";
  };
}