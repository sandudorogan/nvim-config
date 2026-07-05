local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

local captured = {
  keymaps = {},
}

t.stub_module("sandu.lsp.cljs_modules", {
  jump = function()
    return false
  end,
})

t.stub_module("sandu.lsp.watchfiles", {
  preload = function()
    return true
  end,
})

t.patch(vim.api, "nvim_create_augroup", function()
  return 1
end)

t.patch(vim.api, "nvim_create_autocmd", function(event, opts)
  if event == "LspAttach" then
    captured.on_lsp_attach = opts.callback
  end

  return 1
end)

t.patch(vim.keymap, "set", function(mode, lhs, rhs, opts)
  table.insert(captured.keymaps, {
    mode = mode,
    lhs = lhs,
    rhs = rhs,
    opts = vim.deepcopy(opts),
  })
end)

t.patch(vim.lsp, "enable", function() end)
t.patch(vim.lsp.inlay_hint, "enable", function() end)
t.patch(vim.diagnostic, "config", function() end)

t.run(function()
  t.load("lua/sandu/lsp.lua")

  assert(type(captured.on_lsp_attach) == "function", "expected LspAttach callback to be registered")

  captured.on_lsp_attach({ buf = 7 })

  local restart_map

  for _, keymap in ipairs(captured.keymaps) do
    if keymap.lhs == "<leader>rs" then
      restart_map = keymap
      break
    end
  end

  assert(restart_map ~= nil, "expected <leader>rs to be configured")
  assert(type(restart_map.rhs) == "function", "expected <leader>rs to call a restart helper")

  local enable_calls = {}

  t.patch(vim.lsp, "get_clients", function(opts)
    assert(opts.bufnr == 7, "expected restart helper to scope clients to the attached buffer")

    return {
      { name = "clojure_lsp" },
      { name = "ts_ls" },
    }
  end)

  t.patch(vim.lsp, "enable", function(name, enable)
    table.insert(enable_calls, { names = name, enabled = enable ~= false })
  end)

  t.patch(vim, "defer_fn", function(callback)
    callback()
  end)

  restart_map.rhs()

  assert(
    vim.deep_equal(enable_calls, {
      { names = { "clojure_lsp", "ts_ls" }, enabled = false },
      { names = { "clojure_lsp", "ts_ls" }, enabled = true },
    }),
    "expected restart helper to disable and re-enable every client attached to the buffer"
  )
end)
