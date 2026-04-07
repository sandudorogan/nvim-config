local project_root_markers = {
  "package-lock.json",
  "yarn.lock",
  "pnpm-lock.yaml",
  "bun.lockb",
  "bun.lock",
  "deno.lock",
}

local root_markers = vim.fn.has("nvim-0.11.3") == 1
    and { project_root_markers, { ".git" } }
  or vim.list_extend(vim.deepcopy(project_root_markers), { ".git" })

return {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_dir = function(bufnr, on_dir)
    local filename = vim.api.nvim_buf_get_name(bufnr)

    if filename ~= "" and vim.uv.fs_stat(filename) ~= nil then
      on_dir(vim.fs.root(bufnr, root_markers) or vim.fn.getcwd())
      return
    end

    on_dir(nil)
  end,
  on_attach = function(client)
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = vim.api.nvim_create_augroup("SvelteTsJsReload", { clear = true }),
      pattern = { "*.js", "*.ts" },
      callback = function(ctx)
        client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
      end,
    })
  end,
}
