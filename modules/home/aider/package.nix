# modules/home/aider/package.nix

{
  pkgs,
  ...
}:
let
  secretName = "OPENROUTER_API_KEY";
  secretPath = "/run/secrets/${secretName}";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "aider" ''
      if [ -f "${secretPath}" ]; then
        export OPENROUTER_API_KEY=$(cat "${secretPath}")
        export AIDER_OPENROUTER_API_KEY="$OPENROUTER_API_KEY"
      else
        echo "⚠️  Secret ${secretPath} not found. Run 'sudo nixos-rebuild switch' and relogin." >&2
      fi
      exec ${pkgs.aider-chat}/bin/aider "$@"
    '')
  ];
}
