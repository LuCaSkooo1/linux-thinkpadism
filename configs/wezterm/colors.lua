-- Thinkpadism colour schemes for WezTerm.
--
-- Two variants, both built around the same red: #b3121d is the red off a
-- ThinkPad lid badge, #e0303c is the brighter version that survives being
-- put on a dark background. The light scheme pairs with the shell's
-- "thinkpad-light" theme, the dark one with "thinkpad-dark".
--
-- ANSI colours are deliberately muted everywhere except red. If eight
-- colours all shout, the accent stops meaning anything.

local M = {}

M.dark = {
    foreground = "#e6e4e1",
    background = "#141414",

    cursor_bg     = "#e0303c",
    cursor_fg     = "#141414",
    cursor_border = "#e0303c",

    selection_fg = "#f5f3f1",
    selection_bg = "#8c1620",

    scrollbar_thumb = "#343434",
    split           = "#343434",

    ansi = {
        "#232323", -- black
        "#c9202b", -- red
        "#7a9a5e", -- green
        "#c9942a", -- yellow
        "#5b7a99", -- blue
        "#97517f", -- magenta
        "#4f8f8a", -- cyan
        "#c9c5c0", -- white
    },
    brights = {
        "#4a4a4a",
        "#ff5a63",
        "#9cbd7c",
        "#e8b44c",
        "#7fa3c4",
        "#bb75a3",
        "#6fb3ad",
        "#f5f3f1",
    },

    tab_bar = {
        background = "#141414",
        active_tab = {
            bg_color  = "#b3121d",
            fg_color  = "#f5f3f1",
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = "#232323",
            fg_color = "#9a9691",
        },
        inactive_tab_hover = {
            bg_color = "#343434",
            fg_color = "#e6e4e1",
        },
        new_tab = {
            bg_color = "#141414",
            fg_color = "#9a9691",
        },
        new_tab_hover = {
            bg_color = "#232323",
            fg_color = "#e0303c",
        },
    },
}

M.light = {
    foreground = "#121212",
    background = "#d6d3ce",

    cursor_bg     = "#b3121d",
    cursor_fg     = "#f2f0ed",
    cursor_border = "#b3121d",

    selection_fg = "#f2f0ed",
    selection_bg = "#b3121d",

    scrollbar_thumb = "#9a9691",
    split           = "#9a9691",

    ansi = {
        "#d6d3ce",
        "#b3121d",
        "#4f6b38",
        "#96690f",
        "#3b5876",
        "#71355c",
        "#2f6b66",
        "#3a3835",
    },
    brights = {
        "#9a9691",
        "#e0303c",
        "#6b8a4e",
        "#b8891f",
        "#527a9e",
        "#8f5077",
        "#448a84",
        "#121212",
    },

    tab_bar = {
        background = "#d6d3ce",
        active_tab = {
            bg_color  = "#b3121d",
            fg_color  = "#f2f0ed",
            intensity = "Bold",
        },
        inactive_tab = {
            bg_color = "#c4c0bb",
            fg_color = "#3a3835",
        },
        inactive_tab_hover = {
            bg_color = "#e2dfda",
            fg_color = "#121212",
        },
        new_tab = {
            bg_color = "#d6d3ce",
            fg_color = "#3a3835",
        },
        new_tab_hover = {
            bg_color = "#e2dfda",
            fg_color = "#b3121d",
        },
    },
}

return M
