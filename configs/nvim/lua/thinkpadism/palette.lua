-- The Thinkpadism palette, as Neovim sees it.
--
-- Same colours as WezTerm, Yazi and the shell. Kept in its own module so
-- the colourscheme and the statusline read from one source.

return {
    -- Backgrounds, darkest first.
    bg        = "#141414",
    bg_alt    = "#1b1b1b", -- floats, statusline
    bg_soft   = "#232323", -- cursorline, visual
    bg_hard   = "#0d0d0d", -- gutter-adjacent, tabline fill

    -- Foregrounds.
    fg        = "#e6e4e1",
    fg_dim    = "#9a9691",
    fg_faint  = "#4a4a4a", -- comments, line numbers, indent guides

    -- The accent.
    red       = "#b3121d",
    red_bright = "#e0303c",
    red_soft  = "#ff5a63",
    red_deep  = "#8c1620", -- selection background

    -- Everything else, deliberately muted.
    green     = "#9cbd7c",
    yellow    = "#e8b44c",
    blue      = "#7fa3c4",
    magenta   = "#bb75a3",
    cyan      = "#6fb3ad",
    orange    = "#d18a4e",

    none      = "NONE",
}
