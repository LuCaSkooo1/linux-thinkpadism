-- Thinkpadism WezTerm configuration.
--
-- Tuned for a ThinkPad T420: Sandy Bridge graphics, a 1366x768 or 1600x900
-- panel, and a keyboard worth using. The guiding idea is the same as the
-- rest of the rice -- a terminal that behaves like a fixed-function device,
-- with no animation, no rounding, and one accent colour.

local wezterm = require("wezterm")
local colors = require("colors")
local act = wezterm.action

local config = wezterm.config_builder()

--------------------------------------------------------------------------
-- APPEARANCE
--------------------------------------------------------------------------

-- Follows the desktop's light/dark setting, which the shell writes to
-- dconf and the XDG portal republishes. Flipping the bar's dark-mode
-- toggle restyles open terminals without restarting them.
local function scheme_for_appearance(appearance)
    if appearance:find("Dark") then
        return colors.dark
    end
    return colors.light
end

config.color_schemes = {
    ["Thinkpadism Dark"]  = colors.dark,
    ["Thinkpadism Light"] = colors.light,
}

wezterm.on("window-config-reloaded", function(window)
    local overrides = window:get_config_overrides() or {}
    local scheme = scheme_for_appearance(window:get_appearance())
    local name = (scheme == colors.dark) and "Thinkpadism Dark" or "Thinkpadism Light"
    if overrides.color_scheme ~= name then
        overrides.color_scheme = name
        window:set_config_overrides(overrides)
    end
end)

config.color_scheme = "Thinkpadism Dark"

--------------------------------------------------------------------------
-- FONT
--------------------------------------------------------------------------

-- JetBrains Mono is the primary; the fallbacks cover the Nerd Font glyphs
-- yazi and the shell prompt use, and then emoji. Listing them explicitly
-- beats letting fontconfig pick something with the wrong metrics.
config.font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", weight = "Regular" },
    { family = "Symbols Nerd Font Mono" },
    { family = "Noto Color Emoji" },
})
config.font_size = 11.0

-- The T420 panel is 1366x768 at ~125 DPI in the common configuration.
-- Full hinting keeps small text crisp on a non-HiDPI display, where
-- subpixel positioning just smears it.
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

-- No ligatures: in a config file, `!=` should look like two characters.
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

--------------------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------------------

config.window_padding = { left = 8, right = 8, top = 8, bottom = 6 }

-- Hyprland draws the border; WezTerm should not draw a second one.
config.window_decorations = "NONE"

-- Near-opaque. Blur is off compositor-side on this hardware, so a lower
-- value here would just make text harder to read.
config.window_background_opacity = 0.98

config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.7 }

config.enable_scroll_bar = false
config.scrollback_lines = 10000

--------------------------------------------------------------------------
-- TABS
--------------------------------------------------------------------------

-- Square, flat tabs, hidden when there is only one.
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.tab_max_width = 28
config.show_new_tab_button_in_tab_bar = false

-- Number the tabs, and mark the one that has unseen output.
wezterm.on("format-tab-title", function(tab)
    local title = tab.active_pane.title
    if #title > 18 then
        title = title:sub(1, 17) .. "…"
    end
    local marker = tab.active_pane.has_unseen_output and "•" or " "
    return string.format(" %d %s%s ", tab.tab_index + 1, title, marker)
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
-- PERFORMANCE (Sandy Bridge, Intel HD 3000)
--------------------------------------------------------------------------

-- The HD 3000 reports OpenGL 3.1 and has no usable Vulkan driver, so the
-- WebGpu front end either falls back to software or misrenders. OpenGL is
-- the right choice here and costs nothing on newer hardware either.
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
