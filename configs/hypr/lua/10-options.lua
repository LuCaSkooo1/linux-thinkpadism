-- Look, feel and input. Everything here is a plain hl.config() call, so
-- `hyprctl reload` picks up edits immediately.

local theme = require("lib.theme")

--------------------------------------------------------------------------
-- MONITORS
--------------------------------------------------------------------------

-- Fallback rule: any output not named explicitly gets its preferred mode,
-- placed automatically, unscaled. The T420's panel is 1366x768 (or 1600x900
-- on the HD+ option) -- neither wants fractional scaling, so scale 1 is
-- right and "auto" would only risk guessing otherwise.
--
-- Machine-specific overrides belong in 90-machine.lua, which the Home
-- Manager module generates and Hyprland loads last.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

--------------------------------------------------------------------------
-- ENVIRONMENT
--------------------------------------------------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt apps: Wayland first, and let the platform theme draw decorations
-- rather than Qt stamping its own title bars over Hyprland's.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Firefox/LibreWolf in native Wayland.
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Tell toolkits and the XDG portals which desktop this is. The portal
-- config keys off XDG_CURRENT_DESKTOP, and the dark-mode setting the shell
-- writes is read back through it -- so getting this wrong is what leaves
-- GTK file choosers stubbornly light.
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

--------------------------------------------------------------------------
-- LOOK AND FEEL
--------------------------------------------------------------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        -- A single pixel. The colour does the work, not the thickness.
        border_size = 1,

        col = {
            active_border   = theme.activeBorder,
            inactive_border = theme.inactiveBorder,
        },

        -- Drag the borders and the gaps between windows to resize.
        resize_on_border = true,

        layout = "dwindle",

        -- See https://wiki.hypr.land/configuring/extra/tearing/ first.
        allow_tearing = false,
    },

    decoration = {
        -- Square corners: the whole point of the rice is a mechanical,
        -- pre-millennium desktop.
        rounding = 0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 2,
            render_power = 4,
            sharp        = true,
            color        = "rgba(000000d9)",
            offset       = { 2, 2 },
        },

        -- Blur is the single most expensive thing a compositor can do, and
        -- a Sandy Bridge HD 3000 has no headroom for it. Off, permanently.
        blur = { enabled = false },
    },

    -- Animations off: instant windows, and a measurable amount of battery
    -- back on a 2011 laptop.
    animations = { enabled = false },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        -- We ship our own wallpapers; no anime mascot, thanks.
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        background_color        = 0x141414,

        -- Drop to a lower refresh rate when nothing on screen is moving.
        vrr = 1,

        -- Don't animate manual resizes -- with animations off this is
        -- already true, but it keeps the intent explicit.
        animate_manual_resizes = false,
    },

    cursor = {
        -- The i915 hardware cursor plane flickers on Sandy Bridge. Render
        -- the cursor in the compositor instead.
        no_hardware_cursors = 1,

        -- Push the XCursor theme into GSettings so CSD GTK apps agree with
        -- the compositor about which cursor they are drawing.
        sync_gsettings_theme = true,
    },
})

--------------------------------------------------------------------------
-- INPUT
--------------------------------------------------------------------------

hl.config({
    input = {
        -- Overridden per-machine in 90-machine.lua, which loads later.
        kb_layout  = "us",
        kb_options = "",

        follow_mouse = 1,

        -- 0 means libinput's own acceleration curve.
        sensitivity = 0,

        -- Fast repeat matters in a TUI-heavy setup.
        repeat_rate  = 40,
        repeat_delay = 300,

        touchpad = {
            -- The T420's touchpad is small and stiff; tapping beats
            -- pressing it.
            tap_to_click         = true,
            natural_scroll       = true,
            disable_while_typing = true,

            -- 1 = enabled with timeout. Lifting mid-drag doesn't drop.
            drag_lock = 1,

            -- The pad is physically tiny, so scrolling across it covers
            -- very little; slow it down rather than overshooting.
            scroll_factor = 0.6,

            -- One/two/three fingers = left/right/middle, regardless of
            -- where on the pad you press.
            clickfinger_behavior = true,
        },
    },

    gestures = {
        workspace_swipe_distance     = 300,
        workspace_swipe_cancel_ratio = 0.3,
    },
})

-- Three fingers sideways moves between workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- The TrackPoint: a touch slower than the touchpad, since it is used for
-- precision work rather than crossing the screen.
--
-- Device names differ between models. Run `hyprctl devices` and copy the
-- one that looks like a pointing stick if this block does nothing.
hl.device({
    name        = "tpps/2-ibm-trackpoint",
    sensitivity = -0.2,
})
hl.device({
    name        = "tpps/2-elan-trackpoint",
    sensitivity = -0.2,
})
