-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================
-- User laptop overrides template.
-- Add lid/display behavior here if you need laptop-specific logic.

-- Examples:
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = "1" })
-- hl.monitor({ output = "eDP-1", disabled = true })

local function read_first_line(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local line = f:read("*l")
  f:close()
  return line
end

local function external_connected()
  local p = io.popen("cat /sys/class/drm/card*-DP-*/status /sys/class/drm/card*-HDMI-*/status 2>/dev/null")
  local out = p and p:read("*a") or ""
  if p then p:close() end
  return out:find("^connected") ~= nil or out:find("\nconnected") ~= nil
end

-- Lid close: remove laptop panel from layout, but only when an external
-- monitor is connected. Without one, disabling eDP-1 leaves Hyprland on a
-- headless FALLBACK output, and hyprlock (started before suspend) ends up
-- there, so the screen stays black after resume.
hl.bind("switch:on:Lid Switch", function()
  if external_connected() then
    hl.monitor({ output = "eDP-1", disabled = true })
  end
end)

-- Lid open: restore laptop panel
hl.bind("switch:off:Lid Switch", function()
  hl.monitor({ output = "eDP-1", disabled = false })
end)

-- The switch binds only fire on lid changes. If the config is loaded (login or
-- reload) while the lid is already shut and an external monitor is connected,
-- keep the laptop panel off.
local lid = read_first_line("/proc/acpi/button/lid/LID1/state") or ""
if lid:find("closed", 1, true) and external_connected() then
  hl.monitor({ output = "eDP-1", disabled = true })
end
