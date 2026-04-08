package.path = table.concat({
  vim.fn.getcwd() .. "/lua/?.lua",
  vim.fn.getcwd() .. "/lua/?/init.lua",
  package.path,
}, ";")

local captured = {}
local original_lualine = package.loaded["lualine"]
local original_lazy_status = package.loaded["lazy.status"]
local original_get_clients = vim.lsp.get_clients

package.loaded["lualine"] = {
  setup = function(opts)
    captured.setup = opts
  end,
}

package.loaded["lazy.status"] = {
  updates = function()
    return "0 updates"
  end,
  has_updates = function()
    return false
  end,
}

local ok, result = pcall(function()
  local spec = dofile(vim.fn.getcwd() .. "/lua/sandu/plugins/neovim/lualine.lua")

  assert(type(spec.config) == "function", "expected lualine plugin spec to expose config()")

  spec.config()

  return captured.setup
end)

local test_ok, test_result = xpcall(function()
  assert(ok, result)
  assert(type(result.sections.lualine_x) == "table", "expected lualine_x section configuration")

  vim.lsp.get_clients = function(opts)
    if opts ~= nil then
      assert(type(opts) == "table", "expected LSP lookup to receive options")
      assert(opts.bufnr == 0, "expected LSP lookup to be scoped to current buffer")
    end

    return {
      { name = "lua_ls" },
      { name = "copilot" },
    }
  end

  local lsp_component

  for _, component in ipairs(result.sections.lualine_x) do
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

  vim.lsp.get_clients = function()
    return {}
  end

  assert(lsp_component.cond() == false, "expected LSP component to hide when no clients are attached")
end, debug.traceback)

package.loaded["lualine"] = original_lualine
package.loaded["lazy.status"] = original_lazy_status
vim.lsp.get_clients = original_get_clients

assert(test_ok, test_result)
