local lockfile_markers = {
  "package-lock.json",
  "yarn.lock",
  "pnpm-lock.yaml",
  "bun.lockb",
  "bun.lock",
}

local project_root_markers = vim.fn.has("nvim-0.11.3") == 1
    and { lockfile_markers, { ".git" } }
  or vim.list_extend(vim.deepcopy(lockfile_markers), { ".git" })

local function root_dir(bufnr)
  local project_root = vim.fs.root(bufnr, project_root_markers)
  local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
  local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })

  if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
    return nil
  end

  if deno_root and (not project_root or #deno_root >= #project_root) then
    return nil
  end

  return project_root or vim.fn.getcwd()
end

return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  init_options = { hostInfo = "neovim" },
  root_dir = function(bufnr, on_dir)
    on_dir(root_dir(bufnr))
  end,
}
