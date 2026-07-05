local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

local captured = {}

t.stub_module("lualine", {
  setup = function(opts)
    captured.setup = opts
  end,
})

t.stub_module("lazy.status", {
  updates = function()
    return "0 updates"
  end,
  has_updates = function()
    return false
  end,
})

t.run(function()
  local spec = t.load("lua/sandu/plugins/neovim/lualine.lua")

  assert(type(spec.config) == "function", "expected lualine plugin spec to expose config()")

  spec.config()

  local setup = captured.setup

  assert(type(setup.sections.lualine_x) == "table", "expected lualine_x section configuration")

  t.patch(vim.lsp, "get_clients", function(opts)
    if opts ~= nil then
      assert(type(opts) == "table", "expected LSP lookup to receive options")
      assert(opts.bufnr == 0, "expected LSP lookup to be scoped to current buffer")
    end

    return {
      { name = "lua_ls" },
      { name = "copilot" },
    }
  end)

  local lsp_component

  for _, component in ipairs(setup.sections.lualine_x) do
    if type(component) == "table" and type(component[1]) == "function" and type(component.cond) == "function" then
      local ok_render, rendered = pcall(component[1])

      if ok_render and rendered == " lua_ls, copilot" then
        lsp_component = component
        break
      end
    end
  end

  assert(type(lsp_component) == "table", "expected lualine_x to include an LSP status component")
  assert(type(lsp_component.cond) == "function", "expected LSP status component to define a visibility condition")
  assert(lsp_component.cond() == true, "expected LSP component to be visible when clients are attached")
  assert(lsp_component[1]() == " lua_ls, copilot", "expected LSP component to render attached client names")

  t.patch(vim.lsp, "get_clients", function()
    return {}
  end)

  assert(lsp_component.cond() == false, "expected LSP component to hide when no clients are attached")
end)
