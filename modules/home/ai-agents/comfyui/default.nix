# modules/home/ai-agents/comfyui/default.nix
# ComfyUI с ROCm (AMD RX 6600). Запуск ручной — только установка пакета.

{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.modules.home.comfyui;
  system = pkgs.stdenv.hostPlatform.system;
  comfyui = inputs.comfyui-nix.packages.${system}.rocm;

  # Сбрасывает унаследованный PYTHONPATH (в qtile он указывает на 3.13 site-packages),
  # иначе python 3.12 comfyui подхватывает чужой PIL и падает с `_imaging` ImportError.
  comfy-ui = pkgs.writeShellScriptBin "comfy-ui" ''
    unset PYTHONPATH
    exec ${comfyui}/bin/comfy-ui "$@"
  '';
in

{
  options.modules.home.comfyui = {
    enable = mkEnableOption "ComfyUI (ROCm)";
  };

  config = mkIf cfg.enable {
    home.packages = [ comfy-ui ];
  };
}