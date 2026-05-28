# modules/nixos/llm/llama-cpp.nix
# ROCm + llama.cpp для AMD RX 6600 (gfx1032 → gfx1030)
{ config, pkgs, lib, inputs, ... }:

let
  system = pkgs.system;
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};

  llama-cpp-rocm = unstable.llama-cpp.override {
    rocmSupport = true;
    cudaSupport = false;
    metalSupport = false;
    blasSupport = true;
  };

  rocmEnv = pkgs.symlinkJoin {
    name = "rocm-combined";
    paths = with pkgs.rocmPackages; [
      clr
      clr.icd
      rocblas
      hipblas
    ];
  };
in
{
  # Драйвер AMD
  services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" ];

  # Графический стек и ROCm
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
      rocmPackages.rocblas
      rocmPackages.hipblas
      mesa
    ];
  };

  # ROCm хардкодит пути в /opt/rocm
  systemd.tmpfiles.rules = [
    "L+ /opt/rocm - - - - ${rocmEnv}"
  ];

  # Доступ к GPU (/dev/kfd, /dev/dri)
  users.users.max.extraGroups = lib.mkAfter [ "video" "render" ];

  # Маскируем RX 6600 (gfx1032) под поддерживаемый gfx1030
  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "10.3.0";
    ROCM_PATH = "/opt/rocm";
  };

  # llama.cpp с ROCm и утилиты диагностики
  environment.systemPackages = [
    llama-cpp-rocm
    pkgs.rocmPackages.rocminfo
  ];
}