# Neovim with its plugins, all from nixpkgs — no plugin manager, nothing
# downloaded at first start. The config itself is in configs/nvim.
#
# Language servers are not included: install the ones you want and the
# config picks them up (see configs/nvim/lua/thinkpadism/plugins.lua).
{pkgs}:
pkgs.neovim.override {
  viAlias = true;
  vimAlias = true;

  configure.packages.thinkpadism.start = with pkgs.vimPlugins; [
    (nvim-treesitter.withPlugins (g: [
      g.bash
      g.c
      g.json
      g.lua
      g.markdown
      g.markdown_inline
      g.nix
      g.python
      g.toml
      g.vim
      g.vimdoc
      g.yaml
    ]))

    plenary-nvim
    telescope-nvim
    telescope-fzf-native-nvim
    oil-nvim
    gitsigns-nvim
    lualine-nvim
    nvim-web-devicons
    which-key-nvim
    comment-nvim
    nvim-autopairs
    indent-blankline-nvim
    flash-nvim

    nvim-lspconfig
    nvim-cmp
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
  ];

  # Telescope's file and text search.
  extraMakeWrapperArgs = "--suffix PATH : ${pkgs.lib.makeBinPath [pkgs.ripgrep pkgs.fd]}";
}
