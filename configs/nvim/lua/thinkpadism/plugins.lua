-- Plugin setup.
--
-- There is no plugin manager here on purpose. Every plugin is installed by
-- Nix through programs.neovim.plugins, so this file only configures what
-- is already on the runtimepath. That means no network at first start, no
-- lockfile that can drift from the flake, and a Neovim that works the
-- moment `nixos-rebuild` finishes.

local p = require("thinkpadism.palette")
local map = vim.keymap.set

-- Configure a plugin only if Nix actually put it there, so trimming the
-- plugin list in Nix never leaves you with a broken config.
local function setup(name, opts, module)
    local ok, mod = pcall(require, module or name)
    if not ok then
        return nil
    end
    if mod.setup then
        mod.setup(opts)
    end
    return mod
end

--------------------------------------------------------------------------
-- Treesitter: syntax, indentation and folds
--------------------------------------------------------------------------

setup("nvim-treesitter.configs", {
    -- Grammars come from Nix; never try to compile one at runtime.
    auto_install = false,
    ensure_installed = {},

    highlight = {
        enable = true,
        -- Regex highlighting on top of treesitter is a real cost on a
        -- dual-core Sandy Bridge, and buys nothing here.
        additional_vim_regex_highlighting = false,
        disable = function(_, buf)
            -- Bail out on very large files rather than hanging.
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            return ok and stats and stats.size > 256 * 1024
        end,
    },
    indent = { enable = true },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            node_decremental = "<bs>",
            scope_incremental = false,
        },
    },
})

--------------------------------------------------------------------------
-- Telescope: find anything
--------------------------------------------------------------------------

local telescope = setup("telescope", {
    defaults = {
        prompt_prefix = "  ",
        selection_caret = "▌ ",
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_strategy = "flex",
        layout_config = {
            -- A 1366x768 panel: prefer a horizontal layout, and only fall
            -- back to vertical when the window is genuinely narrow.
            prompt_position = "top",
            horizontal = { preview_width = 0.5 },
            vertical = { preview_height = 0.4 },
            flex = { flip_columns = 120 },
        },
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        file_ignore_patterns = { "^%.git/", "^result/", "%.lock$" },
        mappings = {
            i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
                ["<Esc>"] = "close",
            },
        },
    },
    pickers = {
        find_files = { hidden = true },
    },
})

if telescope then
    pcall(telescope.load_extension, "fzf")

    local builtin = require("telescope.builtin")
    map("n", "<leader>ff", builtin.find_files,  { desc = "Find files" })
    map("n", "<leader>fg", builtin.live_grep,   { desc = "Grep" })
    map("n", "<leader>fb", builtin.buffers,     { desc = "Buffers" })
    map("n", "<leader>fh", builtin.help_tags,   { desc = "Help" })
    map("n", "<leader>fk", builtin.keymaps,     { desc = "Keymaps" })
    map("n", "<leader>fr", builtin.oldfiles,    { desc = "Recent files" })
    map("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
    map("n", "<leader>fs", builtin.git_status,  { desc = "Git status" })
    map("n", "<leader>fc", builtin.git_commits, { desc = "Git commits" })
    map("n", "<leader>/",  builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })
    -- Grep for the word under the cursor, the single most-used picker.
    map("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
end

--------------------------------------------------------------------------
-- Oil: edit the filesystem like a buffer
--------------------------------------------------------------------------

local oil = setup("oil", {
    default_file_explorer = true,
    columns = { "icon", "permissions", "size" },
    view_options = { show_hidden = true },
    keymaps = {
        ["q"] = "actions.close",
        ["<C-h>"] = false, -- leave window navigation alone
        ["<C-l>"] = false,
    },
    float = { border = "single" },
})

if oil then
    map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
    map("n", "<leader>fo", function() require("oil").toggle_float() end, { desc = "Oil (float)" })
end

--------------------------------------------------------------------------
-- Git
--------------------------------------------------------------------------

local gitsigns = setup("gitsigns", {
    signs = {
        add          = { text = "▌" },
        change       = { text = "▌" },
        delete       = { text = "▁" },
        topdelete    = { text = "▔" },
        changedelete = { text = "▌" },
        untracked    = { text = "┆" },
    },
    current_line_blame = false,
    current_line_blame_opts = { delay = 400, virt_text_pos = "eol" },
    preview_config = { border = "single" },
})

if gitsigns then
    local gs = require("gitsigns")
    map("n", "]c", function() gs.nav_hunk("next") end, { desc = "Next hunk" })
    map("n", "[c", function() gs.nav_hunk("prev") end, { desc = "Previous hunk" })
    map("n", "<leader>gp", gs.preview_hunk,       { desc = "Preview hunk" })
    map("n", "<leader>gr", gs.reset_hunk,         { desc = "Reset hunk" })
    map("n", "<leader>gs", gs.stage_hunk,         { desc = "Stage hunk" })
    map("n", "<leader>gb", gs.blame_line,         { desc = "Blame line" })
    map("n", "<leader>gB", gs.toggle_current_line_blame, { desc = "Toggle inline blame" })
    map("n", "<leader>gd", gs.diffthis,           { desc = "Diff this" })
end

--------------------------------------------------------------------------
-- Statusline
--------------------------------------------------------------------------

setup("lualine", {
    options = {
        theme = {
            normal = {
                a = { fg = "#f5f3f1", bg = p.red, gui = "bold" },
                b = { fg = p.fg,      bg = p.bg_soft },
                c = { fg = p.fg_dim,  bg = p.bg_alt },
            },
            insert  = { a = { fg = p.bg, bg = p.green,  gui = "bold" } },
            visual  = { a = { fg = p.bg, bg = p.yellow, gui = "bold" } },
            replace = { a = { fg = p.bg, bg = p.orange, gui = "bold" } },
            command = { a = { fg = p.bg, bg = p.cyan,   gui = "bold" } },
            inactive = {
                a = { fg = p.fg_faint, bg = p.bg_alt },
                b = { fg = p.fg_faint, bg = p.bg_alt },
                c = { fg = p.fg_faint, bg = p.bg_alt },
            },
        },
        -- Square separators, like everything else in this rice.
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
    },
    sections = {
        lualine_a = { { "mode", fmt = function(s) return s:sub(1, 1) end } },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {
            { "diagnostics", symbols = { error = "E", warn = "W", info = "I", hint = "H" } },
            "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
})

--------------------------------------------------------------------------
-- Quality of life
--------------------------------------------------------------------------

-- which-key: press a prefix, wait, and it tells you what follows. The one
-- plugin that makes a big keymap learnable.
local wk = setup("which-key", {
    preset = "helix",
    win = { border = "single" },
})
if wk then
    wk.add({
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>n", group = "nix" },
        { "<leader>x", group = "diagnostics" },
    })
end

setup("Comment")            -- gcc / gc{motion}
setup("nvim-autopairs", { check_ts = true })
setup("todo-comments", { signs = false })
setup("nvim-web-devicons")

setup("ibl", {
    indent = { char = "│" },
    scope = { enabled = true, show_start = false, show_end = false },
    exclude = { filetypes = { "help", "oil", "lazy", "checkhealth", "man" } },
})

-- flash: s<two chars> to jump anywhere on screen. Replaces most window
-- scrolling.
local flash = setup("flash", {
    modes = { char = { jump_labels = true } },
})
if flash then
    map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
    map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash treesitter" })
end

--------------------------------------------------------------------------
-- Completion
--------------------------------------------------------------------------

local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
    local luasnip_ok, luasnip = pcall(require, "luasnip")

    cmp.setup({
        snippet = {
            expand = function(args)
                if luasnip_ok then
                    luasnip.lsp_expand(args.body)
                end
            end,
        },
        window = {
            completion = cmp.config.window.bordered({ border = "single" }),
            documentation = cmp.config.window.bordered({ border = "single" }),
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            -- Enter only confirms when something is explicitly selected,
            -- so it still inserts a newline the rest of the time.
            ["<CR>"] = cmp.mapping.confirm({ select = false }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip_ok and luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip_ok and luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "path" },
        }, {
            { name = "buffer", keyword_length = 3 },
        }),
    })
end

--------------------------------------------------------------------------
-- Formatting
--------------------------------------------------------------------------

local conform = setup("conform", {
    formatters_by_ft = {
        nix = { "alejandra" },
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        python = { "ruff_format" },
        json = { "jq" },
        markdown = { "prettier" },
        yaml = { "prettier" },
    },
    -- Manual by default: nothing reformats a file out from under you on
    -- save unless you ask.
    format_on_save = false,
})

if conform then
    map({ "n", "x" }, "<leader>cf", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
    end, { desc = "Format" })
end

--------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------

-- Servers are installed by Nix (see nix/neovim.nix). Anything not on
-- PATH is skipped silently rather than erroring on every start.
local servers = {
    nixd = {},
    lua_ls = {
        settings = {
            Lua = {
                runtime = { version = "LuaJIT" },
                -- Neovim's own globals, plus Hyprland's and WezTerm's, so
                -- editing any config in this repo is warning-free.
                diagnostics = { globals = { "vim", "hl", "wezterm" } },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
            },
        },
    },
    pyright = {},
    bashls = {},
    rust_analyzer = {},
}

local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if lspconfig_ok then
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_lsp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_lsp_ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
    end

    for name, opts in pairs(servers) do
        local server = lspconfig[name]
        -- Only start a server whose binary Nix actually installed.
        local cmd = server and server.document_config
            and server.document_config.default_config
            and server.document_config.default_config.cmd
        if server and (not cmd or vim.fn.executable(cmd[1]) == 1) then
            opts.capabilities = capabilities
            server.setup(opts)
        end
    end
end

-- Buffer-local keymaps, attached only where a server is actually running.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("thinkpadism-lsp", { clear = true }),
    callback = function(args)
        local buf = args.buf
        local function bmap(keys, fn, desc)
            map("n", keys, fn, { buffer = buf, desc = "LSP: " .. desc })
        end

        bmap("gd", vim.lsp.buf.definition,      "Definition")
        bmap("gD", vim.lsp.buf.declaration,     "Declaration")
        bmap("gi", vim.lsp.buf.implementation,  "Implementation")
        bmap("gr", vim.lsp.buf.references,      "References")
        bmap("gy", vim.lsp.buf.type_definition, "Type definition")
        bmap("K",  vim.lsp.buf.hover,           "Hover")
        bmap("<leader>cr", vim.lsp.buf.rename,  "Rename")
        bmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("i", "<C-s>", vim.lsp.buf.signature_help, { buffer = buf, desc = "LSP: Signature" })

        -- Inlay hints where the server offers them, off by default
        -- because they cost horizontal space on a small panel.
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
            bmap("<leader>ch", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Toggle inlay hints")
        end
    end,
})
