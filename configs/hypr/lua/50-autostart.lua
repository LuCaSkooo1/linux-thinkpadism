-- Autostart. All independent daemons; the bar reconnects to the tray and
-- to hyprpaper whenever they appear, so order does not matter.

local p = require("lib.programs")

hl.on("hyprland.start", function()
    hl.exec_cmd(p.shell)          -- the bar
    hl.exec_cmd("hyprpaper")      -- wallpaper; the appearance menu drives it
    hl.exec_cmd("mako")           -- notifications
    hl.exec_cmd("hypridle")       -- dim, lock, blank, suspend
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
end)
