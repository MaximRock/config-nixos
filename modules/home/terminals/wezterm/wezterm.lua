local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local keys = require 'keys'
config.keys = keys

local function load_json(path)
    local f = io.open(path, 'r')
    if not f then return nil end
    local content = f:read('*a')
    f:close()
    return wezterm.json_parse(content)
end

local home = os.getenv('HOME')
local s = load_json(home .. '/.config/qtile/settings/settings.json')

local colors = {}
if s then
    local preset = load_json(
        home .. '/.config/qtile/config_qtile/theme/presets/' .. s.theme.active .. '.json'
    )
    if preset and preset[1] and preset[1].config then
        for k, v in pairs(preset[1].config) do colors[k] = v end
    end
    local overrides = s.theme.colors or {}
    for k, v in pairs(overrides) do colors[k] = v end
end

local function wc_or(key, theme_key, default)
    if s and s.wezterm and s.wezterm[key] ~= nil then
        return s.wezterm[key]
    end
    return colors[theme_key] or default
end

if s then
    config.font = wezterm.font(s.wezterm.font_family)
    config.font_size = s.wezterm.font_size
else
    config.font = wezterm.font('JetBrainsMono Nerd Font Mono')
    config.font_size = 14.0
end
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

if s and s.wezterm and s.wezterm.color_scheme_map then
    config.color_scheme = s.wezterm.color_scheme_map[s.theme.active] or 'Tokyo Night'
else
    config.color_scheme = 'Tokyo Night'
end

config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
if s and s.wezterm then
    config.window_background_opacity = s.wezterm.opacity
    local pad = s.wezterm.padding
    config.window_padding = { left = pad, right = pad, top = pad, bottom = pad }
else
    config.window_background_opacity = 0.92
    config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }
end

config.default_cursor_style = wc_or('cursor_style', nil, 'BlinkingUnderline')
config.cursor_thickness = wc_or('cursor_thickness', nil, 2.0)

config.enable_scroll_bar = true
config.scrollback_lines = wc_or('scrollback_lines', nil, 10000)

config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.selection_word_boundary = ' \t\n{}[]()""\'`.,:;!?|<>=@'

local split_color = wc_or('split_color', 'border_color', '#45475a')

local function sb_or(key, theme_key, default)
    if s and s.wezterm and s.wezterm.status_bar and s.wezterm.status_bar[key] ~= nil then
        return s.wezterm.status_bar[key]
    end
    return colors[theme_key] or default
end

local function tab_or(key, theme_key, default)
    if s and s.wezterm and s.wezterm.tab and s.wezterm.tab[key] ~= nil then
        return s.wezterm.tab[key]
    end
    return colors[theme_key] or default
end

config.colors = {
    split = split_color,
    tab_bar = {
        background = colors.surface or '#1e1e2e',
        active_tab = {
            bg_color = tab_or('active_bg', 'primary', '#89b4fa'),
            fg_color = tab_or('active_fg', 'background', '#1e1e2e'),
        },
        inactive_tab = {
            bg_color = tab_or('inactive_bg', 'hover', '#313244'),
            fg_color = tab_or('inactive_fg', 'foreground', '#cdd6f4'),
        },
        inactive_tab_hover = {
            bg_color = tab_or('hover_bg', 'selected', '#585b70'),
            fg_color = tab_or('inactive_fg', 'foreground', '#cdd6f4'),
        },
        new_tab = {
            bg_color = colors.surface or '#1e1e2e',
            fg_color = colors.primary or '#89b4fa',
        },
        new_tab_hover = {
            bg_color = colors.hover or '#313244',
            fg_color = colors.primary or '#89b4fa',
            italic = true,
        },
    },
}

config.audible_bell = 'Disabled'
config.visual_bell = { target = 'CursorColor' }

local sb_hostname = sb_or('hostname_color', 'primary', '#89b4fa')
local sb_separator = sb_or('separator_color', 'separator_color', '#585b70')
local sb_date = sb_or('date_color', 'foreground', '#cdd6f4')

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

return config
