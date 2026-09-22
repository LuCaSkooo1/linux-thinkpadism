-- The "thinkpadism" colourscheme.
--
-- Hand-written rather than pulled from a plugin, so it matches the rest of
-- the rice exactly and has no upstream that can restyle itself out from
-- under you. Red is reserved for things that matter: keywords, errors, the
-- cursor line number, the mode indicator. Everything else is grey with a
-- little colour.

local p = require("thinkpadism.palette")

local M = {}

function M.load()
    vim.cmd.highlight("clear")
    if vim.fn.exists("syntax_on") == 1 then
        vim.cmd.syntax("reset")
    end

    vim.o.background = "dark"
    vim.g.colors_name = "thinkpadism"

    local hl = vim.api.nvim_set_hl

    local groups = {
        --------------------------------------------------------------
        -- Editor chrome
        --------------------------------------------------------------
        Normal       = { fg = p.fg, bg = p.bg },
        -- Floats sit a shade lighter so they read as on top of the buffer
        -- rather than cut into it.
        NormalFloat  = { fg = p.fg, bg = p.bg_alt },
        FloatBorder  = { fg = p.red, bg = p.bg_alt },
        FloatTitle   = { fg = p.red_bright, bg = p.bg_alt, bold = true },

        Cursor       = { fg = p.bg, bg = p.red_bright },
        lCursor      = { fg = p.bg, bg = p.red_bright },
        CursorLine   = { bg = p.bg_soft },
        CursorColumn = { bg = p.bg_soft },
        -- The current line number is the one piece of chrome that gets the
        -- accent, so your eye can find the cursor without hunting.
        CursorLineNr = { fg = p.red_bright, bold = true },
        LineNr       = { fg = p.fg_faint },

        SignColumn   = { fg = p.fg_faint, bg = p.none },
        FoldColumn   = { fg = p.fg_faint, bg = p.none },
        Folded       = { fg = p.fg_dim, bg = p.bg_soft },

        ColorColumn  = { bg = p.bg_soft },
        Conceal      = { fg = p.fg_faint },

        VertSplit    = { fg = p.bg_soft },
        WinSeparator = { fg = p.bg_soft },

        StatusLine   = { fg = p.fg, bg = p.bg_alt },
        StatusLineNC = { fg = p.fg_faint, bg = p.bg_alt },

        TabLine      = { fg = p.fg_dim, bg = p.bg_hard },
        TabLineFill  = { bg = p.bg_hard },
        TabLineSel   = { fg = p.fg, bg = p.red, bold = true },

        Visual       = { bg = p.red_deep },
        VisualNOS    = { bg = p.red_deep },

        Search       = { fg = p.bg, bg = p.yellow },
        IncSearch    = { fg = p.bg, bg = p.red_bright, bold = true },
        CurSearch    = { fg = p.bg, bg = p.red_bright, bold = true },
        MatchParen   = { fg = p.red_bright, bold = true, underline = true },

        Pmenu        = { fg = p.fg, bg = p.bg_alt },
        PmenuSel     = { fg = p.fg, bg = p.red_deep, bold = true },
        PmenuSbar    = { bg = p.bg_soft },
        PmenuThumb   = { bg = p.fg_faint },

        WildMenu     = { fg = p.bg, bg = p.red_bright },
        QuickFixLine = { bg = p.bg_soft, bold = true },

        Directory    = { fg = p.red_bright, bold = true },
        Title        = { fg = p.red_bright, bold = true },
        Question     = { fg = p.green },
        MoreMsg      = { fg = p.green },
        ModeMsg      = { fg = p.fg, bold = true },
        ErrorMsg     = { fg = p.red_soft, bold = true },
        WarningMsg   = { fg = p.yellow },
        NonText      = { fg = p.fg_faint },
        SpecialKey   = { fg = p.fg_faint },
        Whitespace   = { fg = p.fg_faint },
        EndOfBuffer  = { fg = p.bg },

        --------------------------------------------------------------
        -- Syntax
        --------------------------------------------------------------
        Comment      = { fg = p.fg_faint, italic = true },

        Constant     = { fg = p.orange },
        String       = { fg = p.green },
        Character    = { fg = p.green },
        Number       = { fg = p.orange },
        Boolean      = { fg = p.orange },
        Float        = { fg = p.orange },

        Identifier   = { fg = p.fg },
        Function     = { fg = p.blue },

        -- Keywords carry the accent: in a wall of grey, the control flow
        -- is what you want to pick out first.
        Statement    = { fg = p.red_bright },
        Conditional  = { fg = p.red_bright },
        Repeat       = { fg = p.red_bright },
        Label        = { fg = p.red_bright },
        Operator     = { fg = p.fg_dim },
        Keyword      = { fg = p.red_bright },
        Exception    = { fg = p.red_soft },

        PreProc      = { fg = p.magenta },
        Include      = { fg = p.magenta },
        Define       = { fg = p.magenta },
        Macro        = { fg = p.magenta },
        PreCondit    = { fg = p.magenta },

        Type         = { fg = p.yellow },
        StorageClass = { fg = p.yellow },
        Structure    = { fg = p.yellow },
        Typedef      = { fg = p.yellow },

        Special      = { fg = p.cyan },
        SpecialChar  = { fg = p.cyan },
        Tag          = { fg = p.cyan },
        Delimiter    = { fg = p.fg_dim },
        SpecialComment = { fg = p.fg_dim, italic = true },
        Debug        = { fg = p.red_soft },

        Underlined   = { underline = true },
        Ignore       = { fg = p.fg_faint },
        Error        = { fg = p.red_soft, bold = true },
        Todo         = { fg = p.bg, bg = p.yellow, bold = true },

        --------------------------------------------------------------
        -- Diagnostics
        --------------------------------------------------------------
        DiagnosticError = { fg = p.red_soft },
        DiagnosticWarn  = { fg = p.yellow },
        DiagnosticInfo  = { fg = p.blue },
        DiagnosticHint  = { fg = p.cyan },
        DiagnosticOk    = { fg = p.green },

        DiagnosticUnderlineError = { sp = p.red_soft, undercurl = true },
        DiagnosticUnderlineWarn  = { sp = p.yellow,   undercurl = true },
        DiagnosticUnderlineInfo  = { sp = p.blue,     undercurl = true },
        DiagnosticUnderlineHint  = { sp = p.cyan,     undercurl = true },

        DiagnosticVirtualTextError = { fg = p.red_soft, bg = p.bg_soft },
        DiagnosticVirtualTextWarn  = { fg = p.yellow,   bg = p.bg_soft },
        DiagnosticVirtualTextInfo  = { fg = p.blue,     bg = p.bg_soft },
        DiagnosticVirtualTextHint  = { fg = p.cyan,     bg = p.bg_soft },

        --------------------------------------------------------------
        -- Diffs
        --------------------------------------------------------------
        DiffAdd      = { fg = p.green,  bg = "#1c2318" },
        DiffChange   = { fg = p.yellow, bg = "#231f18" },
        DiffDelete   = { fg = p.red_soft, bg = "#251618" },
        DiffText     = { fg = p.fg, bg = "#3a2a18", bold = true },

        --------------------------------------------------------------
        -- Treesitter
        --------------------------------------------------------------
        ["@variable"]           = { fg = p.fg },
        ["@variable.builtin"]   = { fg = p.red_soft, italic = true },
        ["@variable.parameter"] = { fg = p.fg, italic = true },
        ["@variable.member"]    = { fg = p.cyan },

        ["@constant"]           = { fg = p.orange },
        ["@constant.builtin"]   = { fg = p.orange, italic = true },
        ["@constant.macro"]     = { fg = p.magenta },

        ["@module"]             = { fg = p.yellow },
        ["@label"]              = { fg = p.red_bright },

        ["@string"]             = { fg = p.green },
        ["@string.escape"]      = { fg = p.cyan },
        ["@string.special"]     = { fg = p.cyan },
        ["@character"]          = { fg = p.green },

        ["@function"]           = { fg = p.blue },
        ["@function.builtin"]   = { fg = p.blue, italic = true },
        ["@function.method"]    = { fg = p.blue },
        ["@constructor"]        = { fg = p.yellow },

        ["@keyword"]            = { fg = p.red_bright },
        ["@keyword.function"]   = { fg = p.red_bright },
        ["@keyword.return"]     = { fg = p.red_soft, bold = true },
        ["@keyword.operator"]   = { fg = p.red_bright },
        ["@keyword.import"]     = { fg = p.magenta },
        ["@keyword.exception"]  = { fg = p.red_soft },

        ["@type"]               = { fg = p.yellow },
        ["@type.builtin"]       = { fg = p.yellow, italic = true },
        ["@attribute"]          = { fg = p.magenta },
        ["@property"]           = { fg = p.cyan },

        ["@operator"]           = { fg = p.fg_dim },
        ["@punctuation.delimiter"] = { fg = p.fg_dim },
        ["@punctuation.bracket"]   = { fg = p.fg_dim },
        ["@punctuation.special"]   = { fg = p.cyan },

        ["@comment"]            = { fg = p.fg_faint, italic = true },
        ["@comment.todo"]       = { fg = p.bg, bg = p.yellow, bold = true },
        ["@comment.warning"]    = { fg = p.bg, bg = p.orange, bold = true },
        ["@comment.error"]      = { fg = p.fg, bg = p.red, bold = true },
        ["@comment.note"]       = { fg = p.bg, bg = p.cyan, bold = true },

        ["@markup.heading"]     = { fg = p.red_bright, bold = true },
        ["@markup.link"]        = { fg = p.blue, underline = true },
        ["@markup.link.url"]    = { fg = p.blue, underline = true },
        ["@markup.raw"]         = { fg = p.green },
        ["@markup.list"]        = { fg = p.red_bright },
        ["@markup.strong"]      = { bold = true },
        ["@markup.italic"]      = { italic = true },
        ["@markup.strikethrough"] = { strikethrough = true },

        ["@diff.plus"]          = { fg = p.green },
        ["@diff.minus"]         = { fg = p.red_soft },
        ["@diff.delta"]         = { fg = p.yellow },

        ["@tag"]                = { fg = p.red_bright },
        ["@tag.attribute"]      = { fg = p.yellow },
        ["@tag.delimiter"]      = { fg = p.fg_dim },

        --------------------------------------------------------------
        -- LSP
        --------------------------------------------------------------
        ["@lsp.type.namespace"] = { link = "@module" },
        ["@lsp.type.parameter"] = { link = "@variable.parameter" },
        ["@lsp.type.property"]  = { link = "@property" },
        LspReferenceText        = { bg = p.bg_soft },
        LspReferenceRead        = { bg = p.bg_soft },
        LspReferenceWrite       = { bg = p.bg_soft, underline = true },
        LspInlayHint            = { fg = p.fg_faint, bg = p.bg_alt, italic = true },
        LspSignatureActiveParameter = { fg = p.red_bright, bold = true },

        --------------------------------------------------------------
        -- Plugins
        --------------------------------------------------------------
        GitSignsAdd    = { fg = p.green },
        GitSignsChange = { fg = p.yellow },
        GitSignsDelete = { fg = p.red_soft },

        TelescopeNormal       = { fg = p.fg, bg = p.bg_alt },
        TelescopeBorder       = { fg = p.red, bg = p.bg_alt },
        TelescopeTitle        = { fg = p.fg, bg = p.red, bold = true },
        TelescopeSelection    = { bg = p.red_deep, bold = true },
        TelescopeMatching     = { fg = p.red_bright, bold = true },
        TelescopePromptPrefix = { fg = p.red_bright },

        WhichKey          = { fg = p.red_bright, bold = true },
        WhichKeyGroup     = { fg = p.yellow },
        WhichKeyDesc      = { fg = p.fg },
        WhichKeySeparator = { fg = p.fg_faint },
        WhichKeyFloat     = { bg = p.bg_alt },

        IblIndent = { fg = "#242424" },
        IblScope  = { fg = p.red_deep },

        FlashLabel  = { fg = p.bg, bg = p.red_bright, bold = true },
        FlashMatch  = { fg = p.fg, bg = p.red_deep },
        FlashCurrent = { fg = p.bg, bg = p.yellow, bold = true },

        OilDir     = { fg = p.red_bright, bold = true },
        OilDirIcon = { fg = p.red_bright },
        OilLink    = { fg = p.blue },
        OilFile    = { fg = p.fg },

        CmpItemAbbrMatch     = { fg = p.red_bright, bold = true },
        CmpItemAbbrMatchFuzzy = { fg = p.red_soft },
        CmpItemKind          = { fg = p.yellow },
        CmpItemMenu          = { fg = p.fg_faint },

        NotifyERRORBorder = { fg = p.red },
        NotifyWARNBorder  = { fg = p.yellow },
        NotifyINFOBorder  = { fg = p.blue },
    }

    for group, spec in pairs(groups) do
        hl(0, group, spec)
    end

    -- Terminal colours inside :terminal, so a shell opened in Neovim
    -- matches WezTerm.
    vim.g.terminal_color_0  = "#232323"
    vim.g.terminal_color_1  = "#c9202b"
    vim.g.terminal_color_2  = "#7a9a5e"
    vim.g.terminal_color_3  = "#c9942a"
    vim.g.terminal_color_4  = "#5b7a99"
    vim.g.terminal_color_5  = "#97517f"
    vim.g.terminal_color_6  = "#4f8f8a"
    vim.g.terminal_color_7  = "#c9c5c0"
    vim.g.terminal_color_8  = "#4a4a4a"
    vim.g.terminal_color_9  = "#ff5a63"
    vim.g.terminal_color_10 = "#9cbd7c"
    vim.g.terminal_color_11 = "#e8b44c"
    vim.g.terminal_color_12 = "#7fa3c4"
    vim.g.terminal_color_13 = "#bb75a3"
    vim.g.terminal_color_14 = "#6fb3ad"
    vim.g.terminal_color_15 = "#f5f3f1"
end

return M
