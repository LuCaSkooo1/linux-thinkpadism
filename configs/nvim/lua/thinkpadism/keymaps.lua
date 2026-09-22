-- Keymaps that do not belong to a plugin. Plugin keymaps live next to
-- their setup() call in plugins.lua.

local map = vim.keymap.set

--------------------------------------------------------------------------
-- Basics
--------------------------------------------------------------------------

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qall<cr>", { desc = "Quit all" })

-- Move by visual line when a line is wrapped, unless a count was given
-- (so 5j still means five real lines and relative numbers stay honest).
map({ "n", "x" }, "j", function() return vim.v.count > 0 and "j" or "gj" end,
    { expr = true, desc = "Down" })
map({ "n", "x" }, "k", function() return vim.v.count > 0 and "k" or "gk" end,
    { expr = true, desc = "Up" })

-- Keep the cursor in the middle when jumping half a page or through
-- search results, so you never lose your place.
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Paste over a selection without losing the register.
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Delete to the black hole.
map({ "n", "x" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Stay in visual mode while indenting.
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Move the selected lines up and down.
map("x", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

--------------------------------------------------------------------------
-- Windows and buffers
--------------------------------------------------------------------------

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

map("n", "<C-Up>",    "<cmd>resize +2<cr>", { desc = "Taller" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>", { desc = "Shorter" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Narrower" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Wider" })

map("n", "<leader>-", "<cmd>split<cr>",  { desc = "Split below" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader><leader>", "<C-^>", { desc = "Last buffer" })

--------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

--------------------------------------------------------------------------
-- Terminal
--------------------------------------------------------------------------

-- Escape out of a terminal buffer without it eating the key.
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

--------------------------------------------------------------------------
-- This machine
--------------------------------------------------------------------------

-- Straight into the rice. The path is where the flake expects to live;
-- change it here if you keep yours somewhere else.
map("n", "<leader>nr", function()
    vim.cmd.edit(vim.fn.expand("~/linux-thinkpadism/flake.nix"))
    vim.cmd.lcd(vim.fn.expand("~/linux-thinkpadism"))
end, { desc = "Edit the Thinkpadism flake" })
