local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "sandu.plugins.always" },
  { import = "sandu.plugins.neovim", cond = (function() return not vim.g.vscode end) },
  { import = "sandu.plugins.neovim.lsp", cond = (function() return not vim.g.vscode end) },
  { import = "sandu.plugins.neovim.mini", cond = (function() return not vim.g.vscode end) },
  { import = "sandu.plugins.neovim.ai", cond = (function() return not vim.g.vscode end) },
}, 
  {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    enabled = false,
    notify = true,
  },
})
