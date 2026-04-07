local config_markers = {
  ".graphqlrc",
  ".graphqlrc.json",
  ".graphqlrc.yaml",
  ".graphqlrc.yml",
  ".graphqlrc.js",
  ".graphqlrc.ts",
  "graphql.config.js",
  "graphql.config.ts",
  "graphql.config.cjs",
  "graphql.config.mjs",
}

return {
  cmd = { "graphql-lsp", "server", "-m", "stream" },
  filetypes = { "graphql", "javascriptreact", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, config_markers))
  end,
}
