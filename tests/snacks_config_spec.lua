local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

t.run(function()
  local spec = t.load("lua/sandu/plugins/neovim/snacks.lua")

  assert(spec[1] == "folke/snacks.nvim", "expected snacks plugin spec")
  assert(spec.lazy == false, "expected snacks to load at startup")

  local keys = {}
  for _, key in ipairs(spec.keys) do
    keys[key[1]] = key
  end

  local expected = {
    "<leader>ff",
    "<leader>fr",
    "<leader>fs",
    "<leader>fc",
    "<leader>ft",
    "<leader>fk",
    "<leader>fa",
    "<leader>ee",
    "<leader>ef",
    "<leader>lg",
    "<leader>ld",
    "<leader>sm",
    "<leader>fn",
  }

  for _, lhs in ipairs(expected) do
    assert(keys[lhs], ("expected %s to be configured"):format(lhs))
    assert(type(keys[lhs][2]) == "function", ("expected %s to call a snacks function"):format(lhs))
  end

  assert(type(spec.opts.dashboard.preset.keys) == "table", "expected dashboard menu to be configured")
  assert(spec.opts.indent.indent.char == "┊", "expected indent guides to keep the ┊ char")
  assert(spec.opts.words.enabled == false, "expected words to stay disabled")
  assert(type(spec.opts.explorer) == "table", "expected explorer to be enabled")

  local ctrl_t = spec.opts.picker.win.input.keys["<c-t>"]
  assert(ctrl_t and ctrl_t[1] == "trouble_open", "expected <c-t> to open trouble from the picker")
  assert(
    type(spec.opts.picker.actions.trouble_open) == "function",
    "expected a trouble_open action for the picker"
  )
end)
