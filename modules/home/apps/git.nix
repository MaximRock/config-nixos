# modules/home/apps/git.nix

{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "MaximRock";
      user.email = "maxrockvardill@gmail.com";
      extraConfig = {
        init.defaultBranch = "main";
      };
    };
  };
}
