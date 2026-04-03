return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = {
          "haskell",
          "lua",
          "rust",
          "python",
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "nix"
        },
        highlight = { enable = true },
      })
    end,
  },
}
