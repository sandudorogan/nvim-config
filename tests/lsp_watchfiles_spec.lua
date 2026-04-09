package.path = table.concat({
  vim.fn.getcwd() .. "/lua/?.lua",
  vim.fn.getcwd() .. "/lua/?/init.lua",
  package.path,
}, ";")

local original_preload = package.preload["vim.lsp._watchfiles"]
local original_loaded = package.loaded["vim.lsp._watchfiles"]

local test_ok, test_result = xpcall(function()
  local helper = require("sandu.lsp.watchfiles")
  local required = 0

  package.loaded["vim.lsp._watchfiles"] = nil
  package.preload["vim.lsp._watchfiles"] = function()
    required = required + 1
    return { cancel = function() end }
  end

  assert(helper.preload() == true, "expected watchfiles preload to succeed when the module is available")
  assert(required == 1, "expected watchfiles preload to require the module")
  assert(helper.preload() == true, "expected watchfiles preload to stay successful after the first load")
  assert(required == 1, "expected watchfiles preload to rely on package.loaded after the first require")

  package.loaded["vim.lsp._watchfiles"] = nil
  package.preload["vim.lsp._watchfiles"] = function()
    error("missing watchfiles", 0)
  end

  assert(helper.preload() == false, "expected watchfiles preload to fail closed when the module cannot be required")
end, debug.traceback)

package.preload["vim.lsp._watchfiles"] = original_preload
package.loaded["vim.lsp._watchfiles"] = original_loaded

assert(test_ok, test_result)
