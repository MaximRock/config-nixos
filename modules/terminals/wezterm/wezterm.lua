-- ~/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Импорт горячих клавиш из отдельного файла
local keys = require 'keys'
config.keys = keys

-- 1. ШРИФТЫ И ЛИГАТУРЫ
config.font = wezterm.font('JetBrainsMono Nerd Font Mono')
config.font_size = 14.0
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- 2. ЦВЕТОВАЯ СХЕМА TOKYO NIGHT
config.color_scheme = 'Tokyo Night'

-- Ручная настройка цветов Tokyo Night (опционально, для точного соответствия Gogh)
-- Раскомментируйте, если встроенная тема не подходит
--[[
config.colors = {
    foreground = '#c0caf5',
    background = '#1a1b26',
    cursor_bg = '#c0caf5',
    cursor_border = '#c0caf5',
    cursor_fg = '#1a1b26',
    selection_bg = '#33467c',
    selection_fg = '#c0caf5',
    ansi = { '#15161e', '#f7768e', '#9ece6a', '#e0af68', '#7aa2f7', '#ad8ee6', '#449dab', '#787c99' },
    brights = { '#444b6a', '#ff7a93', '#b9f27c', '#ff9e64', '#7da6ff', '#bb9af7', '#0db9d7', '#acb0d0' },
}
--]]

-- 3. ОКНО И ДЕКОРАЦИИ
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.92

-- Отступы внутри окна (padding)
config.window_padding = {
    left = 12,
    right = 12,
    top = 12,
    bottom = 12,
}

-- 4. КУРСОР
config.default_cursor_style = 'BlinkingUnderline'
config.cursor_thickness = 2.0

-- 5. СКРОЛЛБАР
config.enable_scroll_bar = true
config.scrollback_lines = 10000 -- Размер буфера прокрутки

-- 6. ССЫЛКИ И МЫШЬ
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.selection_word_boundary = ' \t\n{}[]()""\'`.,:;!?|<>=@'

-- 7. РАЗДЕЛИТЕЛИ ПАНЕЛЕЙ (SPLIT HANDLES)
config.colors = {
    split = '#414868',
}

-- 8. ЗВУК И УВЕДОМЛЕНИЯ
-- Отключить звуковой сигнал, использовать визуальный
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

