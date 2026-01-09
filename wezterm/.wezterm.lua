-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Catppuccin Frappe'


config.keys = {
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
  -- Make Option-Right equivalent to Alt-f; forward-word
  {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
  {
      key = 'j',
      mods = 'CMD',
      action = wezterm.action.ScrollByLine(2),
    },
    {
      key = 'k',
      mods = 'CMD',
      action = wezterm.action.ScrollByLine(-2),
    }
}

-- and finally, return the configuration to wezterm
return config
