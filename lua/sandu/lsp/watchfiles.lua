local M = {}

function M.preload()
  local ok = pcall(require, "vim.lsp._watchfiles")
  return ok
end

return M
