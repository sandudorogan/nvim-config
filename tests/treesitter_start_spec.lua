local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

local captured = {
  notifications = {},
}

t.patch(vim.api, "nvim_create_augroup", function()
  return 1
end)

t.patch(vim.api, "nvim_create_autocmd", function(event, opts)
  if event == "FileType" then
    captured.filetype_autocmd = opts
  end

  return 1
end)

t.patch(vim.keymap, "set", function() end)

t.patch(vim.fn, "executable", function()
  return 0
end)

t.patch(vim, "notify_once", function(message, level)
  table.insert(captured.notifications, { message = message, level = level })
end)

t.stub_module("nvim-treesitter", {
  setup = function() end,
  install = function()
    return {
      wait = function()
        error("install should be skipped when tree-sitter is not executable")
      end,
    }
  end,
  indentexpr = function()
    return 0
  end,
})

t.run(function()
  local spec = t.load("lua/sandu/plugins/neovim/treesitter.lua")

  assert(type(spec.config) == "function", "expected treesitter plugin spec to expose config()")

  spec.config()

  assert(type(captured.filetype_autocmd) == "table", "expected FileType autocmd to be registered")
  assert(type(captured.filetype_autocmd.callback) == "function", "expected FileType callback")

  local bufnr = vim.api.nvim_create_buf(false, true)

  vim.bo[bufnr].buftype = ""
  vim.bo[bufnr].indentexpr = ""

  t.patch(vim.treesitter, "start", function()
    error("query compile failed")
  end)

  local callback_ok, callback_err = pcall(captured.filetype_autocmd.callback, { buf = bufnr })

  assert(callback_ok, callback_err)
  assert(
    vim.b[bufnr].sandu_treesitter_error:find("query compile failed", 1, true) ~= nil,
    "expected Tree-sitter startup error to be stored on the buffer"
  )
  assert(#captured.notifications == 1, "expected Tree-sitter startup failure to notify once")
  assert(
    captured.notifications[1].message:find("query compile failed", 1, true) ~= nil,
    "expected the notification to include the startup error"
  )
  assert(
    captured.notifications[1].level == vim.log.levels.WARN,
    "expected the notification to be a warning"
  )
  assert(vim.bo[bufnr].indentexpr == "", "expected indentexpr to stay unchanged after startup failure")

  t.patch(vim.treesitter, "start", function() end)

  captured.filetype_autocmd.callback({ buf = bufnr })

  assert(vim.b[bufnr].sandu_treesitter_error == nil, "expected successful startup to clear the error")
  assert(
    vim.bo[bufnr].indentexpr == "v:lua.require'nvim-treesitter'.indentexpr()",
    "expected indentexpr to be enabled after successful startup"
  )
end)
