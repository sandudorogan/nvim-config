local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

local captured = {}

t.stub_module("fidget", {
  setup = function(opts)
    captured.setup = opts
  end,
})

t.stub_module("fidget.integration.nvim-tree", nil)

t.run(function()
  local spec = t.load("lua/sandu/plugins/neovim/ai/codecompanion.lua")

  local fidget_spec
  for _, dependency in ipairs(spec.dependencies) do
    if type(dependency) == "table" and dependency[1] == "j-hui/fidget.nvim" then
      fidget_spec = dependency
      break
    end
  end

  assert(type(fidget_spec) == "table", "expected CodeCompanion to configure fidget.nvim")
  assert(type(fidget_spec.config) == "function", "expected fidget dependency to expose config()")

  fidget_spec.config(fidget_spec, fidget_spec.opts)

  assert(type(captured.setup) == "table", "expected fidget setup to receive options")
  assert(
    vim.deep_equal(captured.setup.notification.window.avoid, { "snacks_picker_list" }),
    "expected fidget to avoid the snacks explorer filetype through window options"
  )
end)
