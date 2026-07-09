{ config, pkgs, lib, themeName, ... }:

let
  terminalLib = import ../lib.nix { inherit pkgs lib; };
  cfg = config.modules.home.terminals.wezterm;

  themeToScheme = {
    catppuccin = "Catppuccin Mocha";
    gruvbox = "Gruvbox Dark (Gogh)";
    tokyonight = "Tokyo Night";
  };
  colorScheme = themeToScheme.${themeName} or "Catppuccin Mocha";
in

{
  options.modules.home.terminals.wezterm =
    terminalLib.mkTerminalOptions "WezTerm" pkgs.wezterm;

  config = lib.mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      package = cfg.package;

      settings = {
        color_scheme = colorScheme;

        font = lib.generators.mkLuaInline ''
          wezterm.font('JetBrainsMono Nerd Font Mono')
        '';
        font_size = 14.0;
        harfbuzz_features = [ "calt=1" "clig=1" "liga=1" ];

        window_decorations = "INTEGRATED_BUTTONS";
        hide_tab_bar_if_only_one_tab = true;
        window_background_opacity = 0.92;
        window_padding = {
          left = 12;
          right = 12;
          top = 12;
          bottom = 12;
        };

        default_cursor_style = "BlinkingUnderline";
        cursor_thickness = 2.0;

        enable_scroll_bar = true;
        scrollback_lines = 10000;

        selection_word_boundary = " \t\n{}[]()\"\"'`.,:;!?|<>=@";
        audible_bell = "Disabled";
        visual_bell = { target = "CursorColor"; };

        hyperlink_rules = lib.generators.mkLuaInline ''
          wezterm.default_hyperlink_rules()
        '';

        keys = lib.generators.mkLuaInline ''
          dofile(os.getenv("HOME") .. "/.config/wezterm/keys.lua")
        '';

        colors = {
          split = "#45475a";
          tab_bar = {
            background = "#1e1e2e";
            active_tab = {
              bg_color = "#89b4fa";
              fg_color = "#1e1e2e";
            };
            inactive_tab = {
              bg_color = "#313244";
              fg_color = "#cdd6f4";
            };
            inactive_tab_hover = {
              bg_color = "#585b70";
              fg_color = "#cdd6f4";
            };
            new_tab = {
              bg_color = "#1e1e2e";
              fg_color = "#89b4fa";
            };
            new_tab_hover = {
              bg_color = "#313244";
              fg_color = "#89b4fa";
              italic = true;
            };
          };
        };
      };

      extraConfig = ''
        local sb_hostname = '#89b4fa'
        local sb_separator = '#585b70'
        local sb_date = '#cdd6f4'

        wezterm.on('update-right-status', function(window, pane)
            local date = wezterm.strftime('%H:%M │ %d.%m.%Y')
            local hostname = wezterm.hostname()
            window:set_right_status(wezterm.format({
                { Foreground = { Color = sb_hostname } },
                { Text = ' ' .. hostname .. ' ' },
                { Foreground = { Color = sb_separator } },
                { Text = '│' },
                { Foreground = { Color = sb_date } },
                { Text = ' ' .. date .. ' ' },
            }))
        end)

        wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
            local title = tab.active_pane.title
            local bar = cfg.colors.tab_bar
            local bg, fg
            if tab.is_active then
                bg = bar.active_tab.bg_color
                fg = bar.active_tab.fg_color
            elseif hover then
                bg = bar.inactive_tab_hover.bg_color
                fg = bar.inactive_tab_hover.fg_color
            else
                bg = bar.inactive_tab.bg_color
                fg = bar.inactive_tab.fg_color
            end
            if #title > max_width then
                title = string.sub(title, 1, max_width - 3) .. '...'
            end
            return {
                { Background = { Color = bg } },
                { Foreground = { Color = fg } },
                { Text = ' ' .. title .. ' ' },
            }
        end)
      '';
    };

    xdg.configFile."wezterm/keys.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${toString ./.}/keys.lua";
  };
}
