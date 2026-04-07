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

local framework_root_markers = {
  "mix.lock",
  "Gemfile.lock",
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

local function contains_tailwind(path)
  return readfile_contains(path, "tailwindcss") or readfile_contains(path, "tailwind")
end

local function upward_file(path, candidates, predicate)
  local found = vim.fs.find(candidates, {
    path = path,
    type = "file",
    upward = true,
  })

  for _, candidate in ipairs(found) do
    if not predicate or predicate(candidate) then
      return candidate
    end
  end

  return nil
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
    local package_json = upward_file(filename, { "package.json" }, contains_tailwind)

    if package_json then
      on_dir(vim.fs.dirname(package_json))
      return
    end

    local framework_root = upward_file(filename, framework_root_markers, contains_tailwind)
    if framework_root then
      on_dir(vim.fs.dirname(framework_root))
      return
    end

    on_dir(vim.fs.root(bufnr, { ".git" }))
  end,
}
