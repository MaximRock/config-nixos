{
  config,
  pkgs,
  lib,
  ...
}:

let
  terminalLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.terminals.yazi;
in

{
  options.modules.home.terminals.yazi = terminalLib.mkTerminalOptions "Yazi" pkgs.yazi;

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      package = cfg.package;
      shellWrapperName = "y";
    };

    home.packages = with pkgs; [
      chafa
      ffmpegthumbnailer
      poppler-utils
      mediainfo
      p7zip
      unzip
      zip
      fd
      ripgrep
      fzf
    ];

    xdg.configFile."yazi/yazi.toml".text = ''
      [mgr]
      ratio          = [ 2, 4, 3 ]
      show_hidden = true
      sort_by = "natural"
      sort_dir_first = true

      [preview]
      max_width = 800
      max_height = 900

      [opener]
      edit = [
        { run = 'nvim "$@"', block = true }
      ]
    '';

    xdg.configFile."yazi/keymap.toml".text = ''
      [[manager.prepend_keymap]]
      on = ["e"]
      run = "open"
      desc = "Open in default editor"

      [[manager.prepend_keymap]]
      on = ["E"]
      run = "shell 'wezterm start -- nvim \"$@\"'"
      desc = "Open in Neovim (new terminal)"
    '';

    xdg.configFile."yazi/theme.toml".text = ''
      [manager]
      cwd = { fg = "#89b4fa" }
      hovered = { fg = "#1e1e2e", bg = "#f38ba8" }
      preview_hovered = { fg = "#1e1e2e", bg = "#a6e3a1" }
    '';
  };
}
