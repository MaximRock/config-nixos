-- ~/.config/wezterm/keys.lua
local wezterm = require 'wezterm'

local keys = {
    -- =========================================================================
    -- УПРАВЛЕНИЕ ВКЛАДКАМИ (TABS)
    -- =========================================================================
    {
        key = 't',
        mods = 'CTRL',
        action = wezterm.action.SpawnTab 'CurrentPaneDomain',
    },
    {
        key = 'q',
        mods = 'CTRL',
        action = wezterm.action.CloseCurrentTab { confirm = false }, -- Не спрашивать при закрытии
    },
    {
        key = 'Tab',
        mods = 'CTRL',
        action = wezterm.action.ActivateTabRelative(1),
    },
    {
        key = 'Tab',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ActivateTabRelative(-1),
    },

    -- =========================================================================
    -- СПЛИТЫ (РАЗДЕЛЕНИЕ ЭКРАНА) - КАК В TMUX
    -- =========================================================================
    {
        key = '|',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
        key = '_',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
        key = 'z',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.TogglePaneZoomState, -- Развернуть панель на весь экран
    },
    {
        key = 'x',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CloseCurrentPane { confirm = false },
    },

    -- =========================================================================
    -- НАВИГАЦИЯ МЕЖДУ ПАНЕЛЯМИ - СТИЛЬ VIM (ALT + hjkl)
    -- =========================================================================
    {
        key = 'h',
        mods = 'ALT',
        action = wezterm.action.ActivatePaneDirection 'Left',
    },
    {
        key = 'l',
        mods = 'ALT',
        action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
        key = 'k',
        mods = 'ALT',
        action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
        key = 'j',
        mods = 'ALT',
        action = wezterm.action.ActivatePaneDirection 'Down',
    },

    -- =========================================================================
    -- БУФЕР ОБМЕНА И КОПИРОВАНИЕ
    -- =========================================================================
    {
        key = 'c',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
    },
    {
        key = 'v',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.PasteFrom 'Clipboard',
    },
    {
        key = 'd',
        mods = 'ALT',
        action = wezterm.action.ActivateCopyMode, -- Режим копирования (как tmux [)
    },

    -- =========================================================================
    -- РАЗМЕР ШРИФТА
    -- =========================================================================
    {
        key = '+',
        mods = 'CTRL',
        action = wezterm.action.IncreaseFontSize,
    },
    {
        key = '-',
        mods = 'CTRL',
        action = wezterm.action.DecreaseFontSize,
    },
    {
        key = '0',
        mods = 'CTRL',
        action = wezterm.action.ResetFontSize,
    },

    -- =========================================================================
    -- ПРОЧЕЕ
    -- =========================================================================
    {
        key = 'r',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ReloadConfiguration, -- Перезагрузить конфиг
    },
    {
        key = 'f',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ToggleFullScreen,
    },
}

return keys

