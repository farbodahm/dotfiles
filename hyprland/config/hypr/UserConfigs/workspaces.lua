-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User workspace rules for Lua workflow.
-- PersistWorkspaceLayout.sh writes workspace layout rules into this file.
-- Keep custom hl.workspace_rule(...) entries here so upgrades preserve them.

-- Example:
-- hl.workspace_rule({
--     workspace = "1",
--     monitor = "eDP-1",
--     layout = "dwindle",
-- })
-- Laptop gets 1-5, external monitor gets 6-10 (they fall back to the laptop when unplugged)
for ws = 1, 5 do
    hl.workspace_rule({ workspace = tostring(ws), monitor = "eDP-1", default = ws == 1 })
end
for ws = 6, 10 do
    hl.workspace_rule({ workspace = tostring(ws), monitor = "desc:Dell Inc. DELL S2722QC 9540J24", default = ws == 6 })
end
