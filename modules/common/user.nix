# modules/common/user.nix
{ config, pkgs, lib, username ? "max", ... }:
{
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    # Пароль задаётся отдельно: $ passwd
  };

  # === User-specific programs ===
  # (уже включено в base.nix: programs.dconf, programs.zsh)
}