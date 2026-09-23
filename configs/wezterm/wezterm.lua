-- Thinkpadism WezTerm configuration.
--
-- Styled to sit next to the bar: the same Monaco face, the same red, a
-- square tab strip that is always there, and a status line with the
-- things you glance at.

local wezterm = require("wezterm")
local colors = require("colors")
local act = wezterm.action

local config = wezterm.config_builder()

--------------------------------------------------------------------------
-- COLOURS: follow the bar
--------------------------------------------------------------------------

-- The bar keeps its theme in settings.json. Reading it from here -- and
-- watching the file -- means flipping dark/light on the bar (SUPER+SHIFT+T)
-- restyles every open terminal, with no dependence on the desktop portal.
local function bar_is_dark()
    local path = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"))
        .. "/thinkpadism/settings.json"
    local f = io.open(path, "r")
    if not f then
        return true
    end
    local text = f:read("*a")
    f:close()
    wezterm.add_to_config_reload_watch_list(path)
    local ok, data = pcall(wezterm.serde.json_decode, text)
    if not ok or type(data) ~= "table" or type(data.settings) ~= "table" then
        return true
    end
    return data.settings.currentTheme ~= "thinkpad-light"
end

local dark = bar_is_dark()
local palette = dark and colors.dark or colors.light

config.color_schemes = {
    ["Thinkpadism Dark"]  = colors.dark,
    ["Thinkpadism Light"] = colors.light,
}
config.color_scheme = dark and "Thinkpadism Dark" or "Thinkpadism Light"

-- The chrome around the tabs, taken from the same palette.
local ui = {
    bar     = dark and "#1b1b1b" or "#c4c0bb",
    text    = palette.foreground,
    dim     = dark and "#9a9691" or "#3a3835",
    accent  = "#b3121d",
    bright  = "#e0303c",
    onRed   = "#f5f3f1",
}

--------------------------------------------------------------------------
-- FONT: the bar's Monaco
--------------------------------------------------------------------------

-- Monaco for the text, so the terminal and the bar read as one thing.
-- JetBrains Mono Nerd Font fills in the icon glyphs Yazi and Neovim use,
-- then emoji.
config.font = wezterm.font_with_fallback({
    "Monaco",
    "JetBrainsMono Nerd Font",
    "Symbols Nerd Font Mono",
    "Noto Color Emoji",
})
config.font_size = 11.0
config.line_height = 1.1

-- No ligatures: `!=` should look like two characters.
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

--------------------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------------------

config.window_padding = { left = 12, right = 12, top = 10, bottom = 8 }

-- Hyprland draws the (red) border; WezTerm should not draw a second one.
config.window_decorations = "NONE"
config.window_background_opacity = 1.0

-- Unfocused splits fade back, so the one you are typing in stands out.
config.inactive_pane_hsb = { saturation = 0.6, brightness = 0.55 }

config.enable_scroll_bar = false
config.scrollback_lines = 10000

--------------------------------------------------------------------------
-- TAB STRIP AND STATUS LINE
--------------------------------------------------------------------------

-- A flat, square strip that is always there -- it carries the status
-- line, so it earns its row even with one tab.
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false
config.status_update_interval = 5000

config.colors = {
    tab_bar = {
        background = ui.bar,
        active_tab = { bg_color = ui.accent, fg_color = ui.onRed, intensity = "Bold" },
        inactive_tab = { bg_color = ui.bar, fg_color = ui.dim },
        inactive_tab_hover = { bg_color = ui.bar, fg_color = ui.bright },
    },
}

-- " 1 nvim " -- numbered, and a red dot on a tab with output you have
-- not looked at yet.
wezterm.on("format-tab-title", function(tab)
    local title = tab.active_pane.title
    if #title > 22 then
        title = title:sub(1, 21) .. "…"
    end
    local cells = {}
    if not tab.is_active and tab.active_pane.has_unseen_output then
        table.insert(cells, { Foreground = { Color = ui.bright } })
        table.insert(cells, { Text = " ●" })
        table.insert(cells, "ResetAttributes")
    end
    table.insert(cells, { Text = string.format(" %d %s ", tab.tab_index + 1, title) })
    return cells
end)

-- Left: a red badge, like the start button on the bar.
-- Right: the current directory and the time.
wezterm.on("update-status", function(window, pane)
    window:set_left_status(wezterm.format({
        { Background = { Color = ui.accent } },
        { Foreground = { Color = ui.onRed } },
        { Attribute = { Intensity = "Bold" } },
        { Text = " ▌THINKPADISM " },
        "ResetAttributes",
        { Background = { Color = ui.bar } },
        { Text = " " },
    }))

    local cwd = ""
    local uri = pane:get_current_working_dir()
    if uri then
        -- A Url object on current WezTerm, a "file://host/path" string on
        -- older ones.
        local path
        if type(uri) == "string" then
            path = uri:gsub("^file://[^/]*", "")
        else
            path = uri.file_path or ""
        end
        local home = os.getenv("HOME") or ""
        cwd = path:gsub("^" .. home:gsub("%p", "%%%0"), "~")
    end

    window:set_right_status(wezterm.format({
        { Background = { Color = ui.bar } },
        { Foreground = { Color = ui.dim } },
        { Text = cwd .. "  " },
        { Background = { Color = ui.accent } },
        { Foreground = { Color = ui.onRed } },
        { Text = " " .. wezterm.strftime("%H:%M") .. " " },
    }))
end)

--------------------------------------------------------------------------
-- CURSOR AND BELL
--------------------------------------------------------------------------

config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0
config.force_reverse_video_cursor = false

-- The bell is a flash, not a noise.
config.audible_bell = "Disabled"
config.visual_bell = {
    fade_in_duration_ms = 60,
    fade_out_duration_ms = 60,
    target = "CursorColor",
}

--------------------------------------------------------------------------
-- PERFORMANCE
--------------------------------------------------------------------------

-- OpenGL rather than WebGpu: it works on old Intel GPUs and inside VMs,
-- where WebGpu often falls back to software without saying so.
config.front_end = "OpenGL"

-- The panel is 60Hz; rendering faster than that only burns battery.
config.max_fps = 60
config.animation_fps = 1

config.term = "wezterm"

--------------------------------------------------------------------------
-- KEYS
--------------------------------------------------------------------------

-- CTRL+SHIFT is the leader for everything, matching the rest of the rice.
config.keys = {
    -- Panes. The splits use the ThinkPad's own mental model: | splits
    -- beside, _ splits below.
    { key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
    { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

    -- Move between panes with vim keys.
    { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
    { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },

    -- Resize panes.
    { key = "LeftArrow",  mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Left", 3 }) },
    { key = "RightArrow", mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Right", 3 }) },
    { key = "UpArrow",    mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Up", 3 }) },
    { key = "DownArrow",  mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Down", 3 }) },

    -- Font size.
    { key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL|SHIFT", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL|SHIFT", action = act.ResetFontSize },

    -- Scrollback: search it, or dump it into $EDITOR.
    { key = "f", mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },
    { key = "x", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
    {
        key = "o",
        mods = "CTRL|SHIFT",
        action = act.EmitEvent("open-scrollback-in-editor"),
    },

    -- Quick select: highlights every URL, path and hash on screen and
    -- copies the one you type the label for. The single best reason to
    -- run WezTerm over anything else.
    { key = "Space", mods = "CTRL|SHIFT", action = act.QuickSelect },
}

-- Dump the scrollback to a temporary file and open it in the editor. Much
-- nicer than scrolling when a build log runs long.
wezterm.on("open-scrollback-in-editor", function(window, pane)
    local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
    local path = os.tmpname()
    local f = io.open(path, "w+")
    if not f then
        return
    end
    f:write(text)
    f:close()
    window:perform_action(
        act.SpawnCommandInNewTab({
            args = { os.getenv("EDITOR") or "nvim", path },
        }),
        pane
    )
end)

-- Patterns QuickSelect offers labels for, beyond the built-in defaults.
config.quick_select_patterns = {
    -- Nix store paths, which are the thing you most often want to copy
    -- out of a build log on this machine.
    "/nix/store/[a-z0-9]{32}-[^\\s\"']+",
    -- Git SHAs.
    "[0-9a-f]{7,40}",
    -- IPv4 addresses.
    "\\d+\\.\\d+\\.\\d+\\.\\d+",
}

--------------------------------------------------------------------------
-- MISC
--------------------------------------------------------------------------

-- Don't ask on close unless something is actually running.
config.window_close_confirmation = "NeverPrompt"
config.skip_close_confirmation_for_processes_named = {
    "bash", "sh", "zsh", "fish", "nu", "tmux",
}

-- Never check GitHub for updates: this is a Nix-managed package.
config.check_for_updates = false

config.automatically_reload_config = true
config.enable_wayland = true

return config
