-- Keybinds.
--
-- Programs come from lib/programs.lua, which the Home Manager module
-- generates with absolute store paths -- so a bind can never launch the
-- wrong binary because $PATH happened to change.

local p = require("lib.programs")

local mod = "SUPER"

--------------------------------------------------------------------------
-- LAUNCHING
--------------------------------------------------------------------------

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(p.terminal),    { description = "Terminal" })
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(p.fileManager), { description = "File manager" })
hl.bind(mod .. " + B",      hl.dsp.exec_cmd(p.browser),     { description = "Browser" })
hl.bind(mod .. " + D",      hl.dsp.exec_cmd(p.menu),        { description = "App launcher" })

-- Terminal tools, each in its own terminal window.
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd(p.tuiFiles),       { description = "Files (TUI)" })
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd(p.tuiNetwork),     { description = "Network (TUI)" })
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd(p.tuiAudio),       { description = "Audio (TUI)" })
hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd(p.tuiPerformance), { description = "Performance (TUI)" })

-- A scratchpad terminal: one keystroke down, one keystroke away again.
hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special("scratch"), { description = "Scratchpad" })
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratch" }),
    { description = "Move window to scratchpad" })

--------------------------------------------------------------------------
-- APPEARANCE
--------------------------------------------------------------------------

hl.bind(mod .. " + T",         hl.dsp.exec_cmd(p.appearanceMenu), { description = "Appearance menu" })
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd(p.toggleDarkMode), { description = "Toggle dark/light" })

--------------------------------------------------------------------------
-- WINDOW MANAGEMENT
--------------------------------------------------------------------------

hl.bind(mod .. " + Q",             hl.dsp.window.close(),                  { description = "Close window" })
hl.bind(mod .. " + F",             hl.dsp.window.fullscreen(),             { description = "Fullscreen" })
hl.bind(mod .. " + SHIFT + F",     hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximize" })
hl.bind(mod .. " + SHIFT + SPACE", hl.dsp.window.float(),                  { description = "Toggle floating" })
hl.bind(mod .. " + P",             hl.dsp.window.pseudo(),                 { description = "Pseudotile" })
hl.bind(mod .. " + J",             hl.dsp.layout("togglesplit"),           { description = "Toggle split" })
hl.bind(mod .. " + C",             hl.dsp.window.center(),                 { description = "Centre window" })
hl.bind(mod .. " + SHIFT + Q",     hl.dsp.exit(),                          { description = "Exit Hyprland" })

-- Focus: arrows and vim keys both. Note SUPER+J is taken by togglesplit
-- above, so "down" is the arrow key or SUPER+N.
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K",     hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + N",     hl.dsp.focus({ direction = "down" }))

-- Move the focused window.
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Resize, repeating while held.
hl.bind(mod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + right", hl.dsp.window.resize({ x =  40, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(mod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0, y =  40, relative = true }), { repeating = true })

-- Alt-Tab: focus the next window and raise it, so it works for floats too.
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end, { description = "Cycle windows" })

--------------------------------------------------------------------------
-- WORKSPACES
--------------------------------------------------------------------------

for i = 1, 10 do
    local key = i % 10 -- workspace 10 sits on the 0 key
    hl.bind(mod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Scroll over the desktop with SUPER held to cycle workspaces.
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Drag to move, right-drag to resize.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------------------------------
-- SCREENSHOTS AND LOCKING
--------------------------------------------------------------------------

hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(p.screenshotRegion), { description = "Screenshot region" })
hl.bind("Print",               hl.dsp.exec_cmd(p.screenshotScreen), { description = "Screenshot screen" })
hl.bind(mod .. " + Escape",    hl.dsp.exec_cmd(p.lock),             { description = "Lock" })
