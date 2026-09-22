# Neovim, with every plugin supplied by Nix.
#
# No plugin manager: the config in configs/nvim only calls setup() on what
# is already on the runtimepath. That means a fresh install has a working
# editor the moment nixos-rebuild finishes, with no network fetch and no
# lockfile that can drift away from this flake.
{
  pkgs,
  lib,
  # Language servers and formatters. Split out so a slimmer install can
  # drop them without losing the editor.
  withTools ? true,
}: let
  inherit (pkgs) vimPlugins;

  # Treesitter grammars, chosen rather than taking withAllGrammars: the
  # full set is several hundred megabytes, which is a real cost on a
  # machine with a small SSD.
  treesitter = vimPlugins.nvim-treesitter.withPlugins (g: [
    g.bash
    g.c
    g.css
    g.diff
    g.git_config
    g.git_rebase
    g.gitcommit
    g.gitignore
    g.html
    g.javascript
    g.json
    g.lua
    g.luadoc
    g.markdown
    g.markdown_inline
    g.nix
    g.python
    g.qmljs
    g.query
    g.regex
    g.rust
    g.toml
    g.vim
    g.vimdoc
    g.yaml
  ]);

  plugins = with vimPlugins; [
    treesitter

    # Finding things.
    plenary-nvim
    telescope-nvim
    telescope-fzf-native-nvim

    # Files, git, status.
    oil-nvim
    gitsigns-nvim
    lualine-nvim
    nvim-web-devicons

    # Editing comfort.
    which-key-nvim
    comment-nvim
    nvim-autopairs
    indent-blankline-nvim
    todo-comments-nvim
    flash-nvim
    vim-sleuth

    # LSP and completion.
    nvim-lspconfig
    nvim-cmp
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    cmp_luasnip
    luasnip
    friendly-snippets

    # Formatting.
    conform-nvim
  ];

  # Binaries Neovim shells out to. The LSP setup in plugins.lua skips any
  # server whose binary is missing, so trimming this list degrades
  # gracefully rather than erroring.
  tools = with pkgs;
    [
      # Telescope's live_grep and find_files.
      ripgrep
      fd
    ]
    ++ lib.optionals withTools [
      # Language servers.
      nixd
      lua-language-server
      pyright
      bash-language-server
      rust-analyzer

      # Formatters, matching conform's formatters_by_ft.
      alejandra
      stylua
      shfmt
      ruff
      jq
      prettier
    ];
in
  pkgs.neovim.override {
    viAlias = true;
    vimAlias = true;

    configure = {
      customRC = ''
        " The Lua tree is installed to ~/.config/nvim by Home Manager, and
        " Neovim loads it on its own. Nothing to do here.
      '';
      packages.thinkpadism = {
        start = plugins;
        opt = [];
      };
    };

    extraMakeWrapperArgs = "--suffix PATH : ${lib.makeBinPath tools}";
  }
