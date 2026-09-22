-- Autocommands.

local group = vim.api.nvim_create_augroup("thinkpadism", { clear = true })

-- Flash the text that was just yanked, so you can see what you got.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 120 })
    end,
})

-- Strip trailing whitespace on save, except where it is meaningful.
vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft == "markdown" or ft == "diff" or ft == "gitsendemail" then
            return
        end
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

-- Reopen a file at the line you left it on.
vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local lines = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= lines then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- q closes these read-only windows, rather than making you :q.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify", "query" },
    callback = function(args)
        vim.bo[args.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
    end,
})

-- Two-space indent where the ecosystem expects it.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "nix", "lua", "yaml", "json", "toml", "html", "css", "javascript", "typescript", "qml" },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
    end,
})

-- Wrap and spell-check prose.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "markdown", "gitcommit", "text" },
    callback = function()
        vim.wo.wrap = true
        vim.wo.spell = true
        vim.bo.textwidth = 80
    end,
})

-- Make a directory that does not exist yet when you write into it.
vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    callback = function(args)
        if args.match:match("^%w%w+://") then
            return
        end
        vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(args.match) or args.match, ":p:h"), "p")
    end,
})

-- Rebalance splits when the terminal is resized -- which happens every
-- time a Hyprland bind moves this window.
vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    command = "tabdo wincmd =",
})
