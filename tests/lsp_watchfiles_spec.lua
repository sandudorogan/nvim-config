local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

t.run(function()
  local helper = require("sandu.lsp.watchfiles")
  local required = 0

  t.patch(package.loaded, "vim.lsp._watchfiles", nil)
  t.patch(package.preload, "vim.lsp._watchfiles", function()
    required = required + 1
    return { cancel = function() end }
  end)

  assert(helper.preload() == true, "expected watchfiles preload to succeed when the module is available")
  assert(required == 1, "expected watchfiles preload to require the module")
  assert(helper.preload() == true, "expected watchfiles preload to stay successful after the first load")
  assert(required == 1, "expected watchfiles preload to rely on package.loaded after the first require")

  t.patch(package.loaded, "vim.lsp._watchfiles", nil)
  t.patch(package.preload, "vim.lsp._watchfiles", function()
    error("missing watchfiles", 0)
  end)

  assert(helper.preload() == false, "expected watchfiles preload to fail closed when the module cannot be required")
end)
