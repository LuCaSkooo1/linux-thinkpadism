-- Thinkpadism palette, shared by every Hyprland Lua module.
--
-- Kept in one place so the compositor chrome, the lock screen and the shell
-- all agree on what "ThinkPad red" means. If you restyle the rice, this is
-- the only file that needs to change.
--
-- autoLoad = false: this is a library, required by the other modules rather
-- than run on its own.

local M = {}

-- The accent. #b3121d is the red off a ThinkPad lid badge; the brighter
-- variant is what reads well against a dark background.
M.red       = "rgb(b3121d)"
M.redBright = "rgb(e0303c)"

-- Chrome greys, matching Config.qml's thinkpad-dark theme.
M.grey      = "rgb(343434)"
M.greyDark  = "rgb(141414)"
M.black     = "rgb(080808)"

-- Border gradient for the focused window: dark red into bright red, at 45
-- degrees. Hyprland accepts a gradient anywhere a colour is taken.
M.activeBorder = { colors = { M.redBright, M.red }, angle = 45 }
M.inactiveBorder = M.grey

return M
