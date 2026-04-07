local local_root_markers = {
  ".emmyrc.json",
  ".luarc.json",
  ".luarc.jsonc",
}

local tool_root_markers = {
  ".luacheckrc",
  ".stylua.toml",
  "stylua.toml",
  "selene.toml",
  "selene.yml",
}

local root_markers = vim.fn.has("nvim-0.11.3") == 1
    and { local_root_markers, tool_root_markers, { ".git" } }
  or vim.list_extend(vim.list_extend(vim.deepcopy(local_root_markers), tool_root_markers), { ".git" })

return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = root_markers,
  settings = {
    Lua = {
      codeLens = { enable = true },
      hint = {
        enable = true,
        semicolon = "Disable",
      },
    },
  },
}
