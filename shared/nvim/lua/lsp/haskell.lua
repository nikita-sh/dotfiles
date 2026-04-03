return {
  {
    "mrcjkb/haskell-tools.nvim",
    version = "^4",
    lazy = false,
    config = function()
      vim.g.haskell_tools = {
        hls = {
          on_attach = function(client, bufnr)
          end,
        },
      }
    end,
  },
}
