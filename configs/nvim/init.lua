-- Linux Thinkpadism — Neovim.
--
-- Plugins are installed by Nix, not by a plugin manager; this tree only
-- configures them. See nix/neovim.nix for the package list.
--
-- Load order matters: options set the leader key before any mapping uses
-- it, and the colourscheme goes on before plugins so their highlight
-- groups land on top of it.

require("thinkpadism.options")
require("thinkpadism.colorscheme").load()
require("thinkpadism.keymaps")
require("thinkpadism.autocmds")
require("thinkpadism.plugins")
