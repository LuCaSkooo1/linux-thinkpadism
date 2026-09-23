-- Look, feel and input. Everything here is a plain hl.config() call, so
-- `hyprctl reload` picks up edits immediately.

local theme = require("lib.theme")

--------------------------------------------------------------------------
-- MONITORS
--------------------------------------------------------------------------

-- Any output: its preferred mode, placed automatically, scaled by DPI.
-- To pin a monitor, add your own hl.monitor() call; see the README.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

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

        -- Blur is the most expensive thing a compositor does. Off.
        blur = { enabled = false },
    },

    -- Animations off: instant windows, and a little battery back.
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
        -- Software cursor: avoids flicker on older Intel GPUs and the
        -- invisible-cursor problem in most virtual machines.
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
        -- Overridden by thinkpadism.keyboardLayout (90-session.lua).
        kb_layout  = "us",
        kb_options = "",

        follow_mouse = 1,

        -- 0 means libinput's own acceleration curve.
        sensitivity = 0,

        -- Fast repeat matters in a TUI-heavy setup.
        repeat_rate  = 40,
        repeat_delay = 300,

        touchpad = {
            tap_to_click         = true,
            natural_scroll       = true,
            disable_while_typing = true,

            -- 1 = enabled with timeout. Lifting mid-drag doesn't drop.
            drag_lock = 1,

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
