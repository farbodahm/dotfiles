-- Plain decorations: thin flat borders, small rounding, no glow, no dimming.
-- Original KoolDots values are in user_decorations.lua.bak-kooldots.

hl.config({
  general = {
    border_size = 2,
    gaps_in = 3,
    gaps_out = 6,
    col = {
      active_border = "rgba(8a8a8aff)",
      inactive_border = "rgba(2a2a2aff)",
    },
  },
})

hl.config({
  decoration = {
    rounding = 4,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,
    dim_inactive = false,
    shadow = {
      enabled = false,
    },
    blur = {
      enabled = true,
      size = 4,
      passes = 2,
      new_optimizations = true,
      xray = false,
      ignore_opacity = true,
      special = true,
      popups = false,
    },
  },
})

hl.config({
  group = {
    col = {
      border_active = "rgba(8a8a8aff)",
      border_inactive = "rgba(2a2a2aff)",
    },
    groupbar = {
      col = {
        active = "rgba(3a3a3aff)",
        inactive = "rgba(1a1a1aff)",
      },
    },
  },
})
