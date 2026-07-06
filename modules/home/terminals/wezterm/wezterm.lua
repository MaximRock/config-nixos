-- ~/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Импорт горячих клавиш из отдельного файла
local keys = require 'keys'
config.keys = keys

-- Загрузка центрального конфига
local settings_path = os.getenv('HOME') .. '/.config/qtile/settings/settings.json'
local f = io.open(settings_path, 'r')
local s = f and wezterm.json_parse(f:read('*a'))
if f then f:close() end
if s then
    -- 1. ШРИФТЫ И ЛИГАТУРЫ
    config.font = wezterm.font(s.wezterm.font_family)
    config.font_size = s.wezterm.font_size
    config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

    -- 2. ЦВЕТОВАЯ СХЕМА ИЗ ЦЕНТРАЛЬНОЙ ТЕМЫ
    local scheme_map = {
        catppuccin = 'Catppuccin Mocha',
        gruvbox = 'Gruvbox (Gogh)',
        tokyonight = 'Tokyo Night',
    }
    config.color_scheme = scheme_map[s.theme.active] or 'Tokyo Night'

    -- 3. ОКНО И ДЕКОРАЦИИ
    config.window_decorations = 'RESIZE'
    config.hide_tab_bar_if_only_one_tab = true
    config.window_background_opacity = s.wezterm.opacity
    local pad = s.wezterm.padding
    config.window_padding = { left = pad, right = pad, top = pad, bottom = pad }
else
    config.font = wezterm.font('JetBrainsMono Nerd Font Mono')
    config.font_size = 14.0
    config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }
    config.color_scheme = 'Tokyo Night'
    config.window_decorations = 'RESIZE'
    config.hide_tab_bar_if_only_one_tab = true
    config.window_background_opacity = 0.92
    config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }
end

-- 4. КУРСОР
config.default_cursor_style = 'BlinkingUnderline'
config.cursor_thickness = 2.0

-- 5. СКРОЛЛБАР
config.enable_scroll_bar = true
config.scrollback_lines = 10000

-- 6. ССЫЛКИ И МЫШЬ
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.selection_word_boundary = ' \t\n{}[]()""\'`.,:;!?|<>=@'

-- 7. РАЗДЕЛИТЕЛИ ПАНЕЛЕЙ (SPLIT HANDLES)
config.colors = {
    split = '#414868',
}

-- 8. ЗВУК И УВЕДОМЛЕНИЯ
config.audible_bell = 'Disabled'
config.visual_bell = {
    target = 'CursorColor',
}

-- 9. СТАТУС БАР (ПРАВАЯ ЧАСТЬ)
wezterm.on('update-right-status', function(window, pane)
    local date = wezterm.strftime('%H:%M │ %d.%m.%Y')
    local hostname = wezterm.hostname()

    window:set_right_status(wezterm.format({
        { Foreground = { Color = '#7aa2f7' } },
        { Text = ' ' .. hostname .. ' ' },
        { Foreground = { Color = '#565f89' } },
        { Text = '│' },
        { Foreground = { Color = '#a9b1d6' } },
        { Text = ' ' .. date .. ' ' },
    }))
end)

-- 10. КАСТОМИЗАЦИЯ ВКЛАДОК
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local title = tab.active_pane.title
    local background = '#24283b'
    local foreground = '#a9b1d6'

    if tab.is_active then
        background = '#7aa2f7'
        foreground = '#1a1b26'
    elseif hover then
        background = '#2f3549'
    end

    if #title > max_width then
        title = string.sub(title, 1, max_width - 3) .. '...'
    end

    return {
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = ' ' .. title .. ' ' },
    }
end)

return config

