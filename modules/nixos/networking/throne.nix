{
  pkgs,
  ...
}:
{
  programs.throne = {
    enable = true;
    # package = pkgs.unstable.throne;
    tunMode.enable = true;
  };
}
