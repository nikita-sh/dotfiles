return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended to use a major version
    lazy = false,   -- This plugin is already lazy-loaded by filetype
    config = function()
      vim.g.rustaceanvim = {
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            -- Add custom keymaps or settings here
          end,
          default_settings = {
            -- rust-analyzer specific settings
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true, -- Enable all cargo features
                loadOutDirsFromCheck = true,
                buildScripts = {
                  enable = true,
                },
              },
              procMacro = {
                enable = true,
              },
              inlayHints = {
                typeHints = { enable = true },
                parameterHints = { enable = true },
                chainingHints = { enable = true },
              },
            },
          },
        },
      }
    end,
  },
}
