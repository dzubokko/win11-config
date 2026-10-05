local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Оболочка
config.default_prog = { "pwsh.exe", "-NoLogo" }

-- Шрифт: Iosevka для текста, Nerd Font для значков
config.font = wezterm.font_with_fallback({ "Iosevka Custom", "JetBrainsMono Nerd Font" })
config.font_size = 13.0
config.cell_width = 1.0
config.line_height = 1.1

-- Тема
config.color_scheme = "Catppuccin Mocha"

-- Окно: без рамки, размытые обои под полупрозрачным фоном
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.82
config.window_padding = { left = 14, right = 14, top = 10, bottom = 6 }
config.adjust_window_size_when_changing_font_size = false

-- Курсор: тонкая мигающая полоса
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Вкладки: снизу, простые, скрыты при одной вкладке
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

config.max_fps = 120
config.front_end = "WebGpu"

-- Ctrl+Alt+O: прозрачность вкл/выкл
wezterm.on("toggle-opacity", function(window)
  local o = window:get_config_overrides() or {}
  if o.window_background_opacity then
    o.window_background_opacity = nil
  else
    o.window_background_opacity = 1.0
  end
  window:set_config_overrides(o)
end)

-- Ctrl+Shift+Alt+E: тёмная / светлая тема
wezterm.on("toggle-colorscheme", function(window)
  local o = window:get_config_overrides() or {}
  if o.color_scheme == "Catppuccin Latte" then
    o.color_scheme = nil
  else
    o.color_scheme = "Catppuccin Latte"
  end
  window:set_config_overrides(o)
end)

config.keys = {
  { key = "H", mods = "CTRL|SHIFT|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "V", mods = "CTRL|SHIFT|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "U", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "I", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "O", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "P", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "9", mods = "CTRL", action = act.PaneSelect },
  { key = "o", mods = "CTRL|ALT", action = act.EmitEvent("toggle-opacity") },
  { key = "E", mods = "CTRL|SHIFT|ALT", action = act.EmitEvent("toggle-colorscheme") },
}

return config


