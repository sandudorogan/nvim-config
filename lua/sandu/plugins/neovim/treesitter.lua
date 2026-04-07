local languages = {
  "json",
  "javascript",
  "typescript",
  "tsx",
  "python",
  "yaml",
  "html",
  "css",
  "prisma",
  "markdown",
  "markdown_inline",
  "svelte",
  "graphql",
  "bash",
  "clojure",
  "fennel",
  "lua",
  "vim",
  "dockerfile",
  "gitignore",
  "query",
  "vimdoc",
  "c",
}

local function highlight_filetypes(parser_names)
  local seen = {}
  local patterns = {}

  for _, lang in ipairs(parser_names) do
    for _, filetype in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      if not seen[filetype] then
        seen[filetype] = true
        patterns[#patterns + 1] = filetype
      end
    end
  end

  table.sort(patterns)
  return patterns
end

local function can_manage_parsers()
  return vim.fn.executable("tree-sitter") == 1
end

local function treesitter_root()
  local runtime_files = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/init.lua", false)
  local init_path = runtime_files[1]
  if not init_path then
    return nil
  end
  return vim.fn.fnamemodify(init_path, ":h:h:h")
end

local function ensure_plugin_runtime()
  local root = treesitter_root()
  if not root then
    return
  end

  local runtime = vim.fs.joinpath(root, "runtime")
  if vim.uv.fs_stat(runtime) and not vim.o.runtimepath:find(runtime, 1, true) then
    vim.o.runtimepath = vim.o.runtimepath .. "," .. runtime
  end
end

local function bundled_parser_path(lang)
  local nvim_root = vim.fn.fnamemodify(vim.v.progpath, ":h:h")
  local path = vim.fs.joinpath(nvim_root, "lib", "nvim", "parser", lang .. ".so")
  if vim.uv.fs_stat(path) then
    return path
  end
end

local function plugin_parser_path(lang)
  local root = treesitter_root()
  if not root then
    return nil
  end

  local path = vim.fs.joinpath(root, "parser", lang .. ".so")
  if vim.uv.fs_stat(path) then
    return path
  end
end

local function site_parser_path(lang)
  local path = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "parser", lang .. ".so")
  if vim.uv.fs_stat(path) then
    return path
  end
end

local function prefer_bundled_parsers()
  for _, lang in ipairs({ "c", "lua", "markdown", "vim", "vimdoc" }) do
    local path = bundled_parser_path(lang)
    if path then
      vim.treesitter.language.add(lang, { path = path })
    end
  end
end

local function register_plugin_parsers(parser_names)
  for _, lang in ipairs(parser_names) do
    if not site_parser_path(lang) then
      local path = plugin_parser_path(lang)
      if path then
        vim.treesitter.language.add(lang, { path = path })
      end
    end
  end
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    {
      "windwp/nvim-ts-autotag",
      config = true,
    },
  },
  config = function()
    local treesitter = require("nvim-treesitter")

    ensure_plugin_runtime()
    prefer_bundled_parsers()

    treesitter.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    register_plugin_parsers(languages)

    if can_manage_parsers() then
      treesitter.install(languages):wait(300000)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("sandu-treesitter-highlight", { clear = true }),
      pattern = highlight_filetypes(languages),
      callback = function(ev)
        vim.treesitter.start(ev.buf)
        if vim.bo[ev.buf].buftype == "" then
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    vim.keymap.set("n", "<C-space>", "v]n", {
      silent = true,
      desc = "Treesitter node selection",
    })
    vim.keymap.set("x", "<C-space>", "an", {
      silent = true,
      desc = "Treesitter node selection",
    })
    vim.keymap.set("x", "<bs>", "in", {
      silent = true,
      desc = "Treesitter node selection",
    })
  end,
}
