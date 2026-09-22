-- Linux Thinkpadism — Neovim.
--
-- Plugins are installed by Nix, not by a plugin manager; this tree only
-- configures them. See nix/neovim.nix for the package list.
--
-- Load order matters: options set the leader key before any mapping uses
-- it, and the colourscheme goes on before plugins so their highlight
-- groups land on top of it.

-- Written by the Home Manager module: paths that depend on where this
-- machine keeps the repo. pcall'd so the config still loads if you run it
-- outside Nix.
pcall(require, "thinkpadism.generated")

require("thinkpadism.options")
require("thinkpadism.colorscheme").load()
require("thinkpadism.keymaps")
require("thinkpadism.autocmds")
require("thinkpadism.plugins")
