# modules/nixos/sops.nix

{ config, pkgs, username, ... }: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets.OPENROUTER_API_KEY = {
      mode = "0440";
      owner = "root";
      group = "keys"; # sops-nix автоматически создаёт эту группу
    };
  };

  # ✅ Безопасно добавляем пользователя в группу keys
  # (не перезаписывает extraGroups, работает даже если другие модули тоже меняют группу)
  users.groups.keys.members = [ username ];
}