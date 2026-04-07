local config_root_markers = {
  "tailwind.config.js",
  "tailwind.config.cjs",
  "tailwind.config.mjs",
  "tailwind.config.ts",
  "postcss.config.js",
  "postcss.config.cjs",
  "postcss.config.mjs",
  "postcss.config.ts",
}

local function readfile_contains(path, text)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return false
  end

  for _, line in ipairs(lines) do
    if line:find(text, 1, true) then
      return true
    end
  end

  return false
end

return {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = {
    "css",
    "html",
    "javascript",
    "javascriptreact",
    "less",
    "scss",
    "svelte",
    "typescript",
    "typescriptreact",
  },
  settings = {
    tailwindCSS = {
      validate = true,
      classAttributes = {
        "class",
        "className",
        "class:list",
        "classList",
        "ngClass",
      },
    },
  },
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    local config_root = vim.fs.root(bufnr, config_root_markers)
    if config_root then
      on_dir(config_root)
      return
    end

    local filename = vim.api.nvim_buf_get_name(bufnr)
    local package_json = vim.fs.find("package.json", {
      path = filename,
      type = "file",
      upward = true,
      limit = 1,
    })[1]

    if package_json and readfile_contains(package_json, '"tailwindcss"') then
      on_dir(vim.fs.dirname(package_json))
      return
    end

    on_dir(nil)
  end,
}
