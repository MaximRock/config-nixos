# home/common/var-default.nix
{
  ...
}:
rec {
  username = "max";
  homeDirectory = "/home";
  stateVersion = "25.11";
  dotFilesDir = "/.dotfiles";
  basePathFilesDir = "${homeDirectory}/${username}/${dotFilesDir}";
}
