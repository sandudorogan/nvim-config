local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

t.run(function()
  local spec = t.load("lua/sandu/plugins/neovim/lsp/blink.lua")

  assert(spec[1] == "saghen/blink.cmp", "expected blink plugin spec")
  assert(type(spec.config) == "function", "expected blink plugin spec to expose config()")
end)
