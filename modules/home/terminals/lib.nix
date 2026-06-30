{ pkgs, lib }:

with lib;

{
  mkTerminalOptions = name: defaultPackage: {
    enable = mkEnableOption "${name} terminal emulator";
    package = mkOption {
      type = types.package;
      default = defaultPackage;
      description = "${name} package to use.";
    };
  };
}
