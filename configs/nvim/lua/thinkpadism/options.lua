-- Editor options.

local o = vim.opt

-- Leader has to be set before any mapping that uses it.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

--------------------------------------------------------------------------
-- Display
--------------------------------------------------------------------------

o.number = true
o.relativenumber = true       -- makes 7j / 12k worth typing
o.cursorline = true
o.signcolumn = "yes"          -- never shifts the text as signs appear
o.termguicolors = true
o.showmode = false            -- the statusline already says it
o.laststatus = 3              -- one statusline across all splits
o.cmdheight = 1
o.pumheight = 12              -- a 768px panel cannot show more than this
o.scrolloff = 6
o.sidescrolloff = 8
o.wrap = false
o.linebreak = true            -- when wrap is on, break at words
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
o.fillchars = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸" }
o.colorcolumn = "80"

--------------------------------------------------------------------------
-- Editing
--------------------------------------------------------------------------

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.shiftround = true
o.smartindent = true
o.breakindent = true

o.ignorecase = true
o.smartcase = true            -- a capital in the pattern makes it sensitive
o.inccommand = "split"        -- live preview of :s
o.hlsearch = true
o.incsearch = true

o.splitright = true
o.splitbelow = true
o.splitkeep = "screen"        -- opening a split doesn't scroll the old one

o.virtualedit = "block"
o.completeopt = { "menu", "menuone", "noselect" }

o.mouse = "a"
o.clipboard = "unnamedplus"   -- wl-clipboard bridges this to Wayland

--------------------------------------------------------------------------
-- Files and history
--------------------------------------------------------------------------

o.undofile = true             -- undo survives closing the file
o.undolevels = 10000
o.swapfile = false
o.backup = false
o.writebackup = false

-- 250ms: fast enough that CursorHold feels instant, slow enough not to
-- thrash a spinning disk or an old SSD.
o.updatetime = 250
o.timeoutlen = 400

o.confirm = true              -- ask rather than refusing to :q a dirty buffer

--------------------------------------------------------------------------
-- Folding, via treesitter
--------------------------------------------------------------------------

o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99              -- everything open until you fold it yourself
o.foldtext = ""

--------------------------------------------------------------------------
-- Performance
--------------------------------------------------------------------------

-- Syntax highlighting a minified file can hang a slow machine; these
-- caps stop that.
o.synmaxcol = 300
o.redrawtime = 1500
o.lazyredraw = false          -- interacts badly with noice-style plugins

-- Providers we do not use. Each one Neovim probes for costs startup time.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0

--------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------

vim.diagnostic.config({
    virtual_text = { prefix = "▌", spacing = 2 },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN]  = "W",
            [vim.diagnostic.severity.INFO]  = "I",
            [vim.diagnostic.severity.HINT]  = "H",
        },
    },
    underline = true,
    update_in_insert = false,  -- do not lint mid-keystroke
    severity_sort = true,
    float = { border = "single", source = true },
})
