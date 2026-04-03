local modules = {
  "options",
  -- "autocmds",
  "mappings",
  -- "commands",
  -- "filetypes",
}

for _, module in ipairs(modules) do
  local ok = pcall(require, "config." .. module)
  if not ok then
    print("Uh oh! The " .. module .. " module failed to load.")
  end
end

require("utils")

local lazypath = vim.fn.stdpath("data") .. "/plugins/lazy.nvim"
if vim.fn.isdirectory(lazypath) == 0 then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup("plugins", {
  default = {
    lazy = true,
  },
  colorschemes = { "gruvbox" },
  performance = {
    cache = {
      enabled = true,
    },
  },
})
