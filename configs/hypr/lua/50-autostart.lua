-- Autostart.
--
-- Anything long-lived that the session needs. Ordering does not matter:
-- these are all independent daemons, and the shell reconnects to the tray
-- and to hyprpaper whenever they appear.

local p = require("lib.programs")

hl.on("hyprland.start", function()
    -- The shell itself, by absolute store path.
    hl.exec_cmd(p.shell)

    -- Wallpaper daemon. The Appearance menu drives it over hyprctl; it
    -- just has to be running.
    hl.exec_cmd("hyprpaper")

    -- Notifications.
    hl.exec_cmd("mako")

    -- Idle: dim, lock, blank, suspend. See hypridle.conf.
    hl.exec_cmd("hypridle")

    -- Polkit agent, so graphical apps can ask for a password.
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Network and bluetooth applets, which land in the shell's tray.
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")

    -- Clipboard history, fed into the launcher.
    hl.exec_cmd("wl-paste --watch cliphist store")

    -- Cursor theme. Set here rather than only through env so that apps
    -- started later in the session agree with the ones started now.
    hl.exec_cmd("hyprctl setcursor " .. p.cursorTheme .. " 24")
end)
