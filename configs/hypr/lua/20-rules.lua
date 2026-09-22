-- Window and workspace rules.

--------------------------------------------------------------------------
-- WORKSPACES
--------------------------------------------------------------------------

-- Ten persistent workspaces, so the taskbar's fixed 1..10 strip always has
-- something to point at instead of reflowing as windows come and go.
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

--------------------------------------------------------------------------
-- WINDOW RULES
--------------------------------------------------------------------------

-- Ignore maximize requests. Apps that maximize themselves on launch fight
-- the tiling layout and always lose badly.
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Small utility windows that have no business being tiled.
hl.window_rule({
    name  = "float-utilities",
    match = { class = "^(nm-connection-editor|blueman-manager|blueman-adapters)$" },
    float = true,
    size  = { 760, 540 },
    center = true,
})

hl.window_rule({
    name  = "float-audio",
    match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" },
    float = true,
    size  = { 760, 540 },
    center = true,
})

hl.window_rule({
    name   = "float-appearance",
    match  = { class = "^(nwg-look|qt6ct|qt5ct)$" },
    float  = true,
    center = true,
})

-- Portal dialogs: file choosers, screencast pickers, permission prompts.
hl.window_rule({
    name  = "float-portals",
    match = { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-hyprland)$" },
    float = true,
    center = true,
})

-- Generic modal dialogs ("Are you sure?") -- tiling these is always wrong.
hl.window_rule({
    name  = "float-modals",
    match = { modal = true },
    float = true,
    center = true,
})

-- Picture-in-picture rides along on every workspace, in the corner.
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
    size  = { 480, 270 },
    move  = { "monitor_w-500", "monitor_h-290" },
})

-- Mullvad's window is a fixed-size panel; tiling it just stretches the
-- artwork.
hl.window_rule({
    name   = "float-mullvad",
    match  = { class = "^(mullvad vpn|Mullvad VPN)$" },
    float  = true,
    size   = { 400, 700 },
    center = true,
})

-- Don't let the idle timer blank the screen during a fullscreen video.
hl.window_rule({
    name         = "idle-inhibit-fullscreen",
    match        = { class = ".*" },
    idle_inhibit = "fullscreen",
})

-- Terminals read as a flat sheet; a shadow under one is just a smear.
hl.window_rule({
    name      = "no-shadow-terminals",
    match     = { class = "^(org.wezfurlong.wezterm|kitty|foot)$" },
    no_shadow = true,
})

-- Fix XWayland drag-and-drop, which otherwise steals focus with an
-- invisible zero-size window.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
