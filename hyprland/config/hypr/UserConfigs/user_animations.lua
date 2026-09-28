-- Plain animations: short, no overshoot, no looping border.
-- Original file is in user_animations.lua.bak-kooldots.

hl.curve("plain", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "plain", style = "popin 90%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "plain", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "plain", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "plain" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "plain" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "plain" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "plain", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 3, bezier = "plain", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 3, bezier = "plain", style = "slide" })
