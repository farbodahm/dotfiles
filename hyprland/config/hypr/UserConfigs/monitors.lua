-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User monitor overrides for Lua workflow.
-- MonitorProfiles.sh writes selected Lua monitor profiles into this file.
-- Keep custom hl.monitor(...) entries here so upgrades preserve them.

-- Example:
hl.monitor({
   output = "eDP-1",
   mode = "preferred",
   position = "0x0",
   scale = "1.666667",
})

-- Dell S2722QC (27" 4K), matched by description so any USB-C/DP port works
hl.monitor({
   output = "desc:Dell Inc. DELL S2722QC 9540J24",
   mode = "preferred",
   position = "1728x0", -- fixed (not auto-right): stays put when eDP-1 is disabled on lid close, else layers (bar/wallpaper) are left at the old offset
   scale = "1.5",
})
