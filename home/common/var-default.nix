# home/common/var-default.nix

{ username, ... }:

let
  homeDirectory = "/home/${username}";
  stateVersion = "25.11";
  dotFilesDir = "/.dotfiles";
  basePathFilesDir = "${homeDirectory}${dotFilesDir}";
in
{
  inherit username homeDirectory stateVersion dotFilesDir basePathFilesDir;
}


# {
#   ...
# }:
# rec {
#   username = "max";
#   homeDirectory = "/home";
#   stateVersion = "25.11";
#   dotFilesDir = "/.dotfiles";
#   basePathFilesDir = "${homeDirectory}/${username}/${dotFilesDir}";
# }
