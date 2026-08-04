{
  config,
  pkgs,
  lib,
  appThemeNames,
  appColors,
  ...
}:

let
  terminalLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.terminals.yazi;
  editor = "nvim";

  themeName = cfg.themeName or appThemeNames.yazi;
  colors = cfg.colors or appColors.yazi;

  # ── Flavor sources ──────────────────────────────────────────
  flavorsSrc = {
    catppuccin-mocha = pkgs.fetchFromGitHub {
      owner = "yazi-rs";
      repo = "flavors";
      rev = "4770a3467169bfdb0a3b11601921aaf27c100630";
      hash = "sha256-erZI0H5TxqFu2P917juL5PIB3LC0oJGKPcB1VibJDqo=";
    };
    gruvbox-dark = pkgs.fetchFromGitHub {
      owner = "bennyyip";
      repo = "gruvbox-dark.yazi";
      rev = "619fdc5844db0c04f6115a62cf218e707de2821e";
      hash = "sha256-Y/i+eS04T2+Sg/Z7/CGbuQHo5jxewXIgORTQm25uQb4=";
    };
    tokyo-night = pkgs.fetchFromGitHub {
      owner = "BennyOe";
      repo = "tokyo-night.yazi";
      rev = "8e6296f14daff24151c736ebd0b9b6cd89b02b03";
      hash = "sha256-LArhRteD7OQRBguV1n13gb5jkl90sOxShkDzgEf3PA0=";
    };
  };

  # Map theme name → flavor directory name (without .yazi)
  # Monorepo flavors are subdirectories of the source.
  themeFlavorMap = {
    catppuccin = "catppuccin-mocha";
    gruvbox = "gruvbox-dark";
    tokyonight = "tokyo-night";
  };

  activeFlavorName = themeFlavorMap.${themeName} or "catppuccin-mocha";

  # For single-repo flavors the source root IS the flavor dir.
  # For the yazi-rs/flavors monorepo we must extract the subdirectory.
  flavorDirs = {
    catppuccin-mocha = pkgs.runCommandLocal "catppuccin-mocha.yazi" { } ''
      cp -r ${flavorsSrc.catppuccin-mocha}/catppuccin-mocha.yazi $out
    '';
    gruvbox-dark = flavorsSrc.gruvbox-dark;
    tokyo-night = flavorsSrc.tokyo-night;
  };
in

{
  options.modules.home.terminals.yazi = terminalLib.mkTerminalOptions "Yazi" pkgs.yazi // {
    themeName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Override theme name for Yazi flavor";
    };
    colors = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
      default = null;
      description = "Override color palette for Yazi theme";
    };
  };

  config = lib.mkIf cfg.enable {
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

    programs.yazi = {
      enable = true;
      package = cfg.package;
      shellWrapperName = "y";

      flavors = flavorDirs;

      theme = {
        flavor.dark = activeFlavorName;
        manager = {
          cwd = { fg = "${colors.primary}"; };
          hovered = { fg = "${colors.background}"; bg = "${colors.error}"; };
          preview_hovered = { fg = "${colors.background}"; bg = "${colors.success}"; };
        };
      };

      settings = {
        mgr = {
          ratio = [ 2 4 3 ];
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
        };
        preview = {
          max_width = 800;
          max_height = 900;
        };
        opener = {
          edit = [
            { run = ''nvim "$@"''; block = true; }
          ];
        };
      };

      keymap = {
        manager.prepend_keymap = [
          {
            on = [ "e" ];
            run = "open";
            desc = "Open in default editor";
          }
          {
            on = [ "E" ];
            run = ''shell 'wezterm start -- nvim "$@"' '';
            desc = "Open in Neovim (new terminal)";
          }
        ];
      };
    };
  };
}
