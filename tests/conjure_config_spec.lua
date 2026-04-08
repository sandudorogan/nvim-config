package.path = table.concat({
  vim.fn.getcwd() .. "/lua/?.lua",
  vim.fn.getcwd() .. "/lua/?/init.lua",
  package.path,
}, ";")

local spec = dofile(vim.fn.getcwd() .. "/lua/sandu/plugins/neovim/conjure.lua")
local conjure = spec[1]

assert(type(conjure.init) == "function", "expected conjure plugin spec to expose init()")

local deferred_callback
local deferred_delay
local connect_calls = 0
local last_connect_opts
local original_defer_fn = vim.defer_fn
local original_fs_root = vim.fs.root
local original_action = package.loaded["conjure.client.clojure.nrepl.action"]
local original_action_preload = package.preload["conjure.client.clojure.nrepl.action"]

package.loaded["conjure.client.clojure.nrepl.action"] = nil
package.preload["conjure.client.clojure.nrepl.action"] = function()
  return {
    ["connect-port-file"] = function(opts)
      connect_calls = connect_calls + 1
      last_connect_opts = opts
    end,
  }
end

vim.defer_fn = function(callback, delay)
  deferred_callback = callback
  deferred_delay = delay
end

vim.fs.root = function(bufnr, markers)
  assert(type(bufnr) == "number", "expected root lookup to receive a buffer number")
  assert(type(markers) == "table", "expected root lookup to receive root markers")

  local name = vim.api.nvim_buf_get_name(bufnr)

  if name:find("other%-project", 1, false) then
    return "/tmp/other-project"
  end

  return "/tmp/project"
end

conjure.init()

local configured_filetypes = vim.g["conjure#filetypes"]

assert(type(configured_filetypes) == "table", "expected g:conjure#filetypes to be configured")
assert(vim.g["conjure#client_on_load"] == false, "expected Conjure client_on_load to be disabled")
assert(connect_calls == 0, "expected Conjure init() to avoid immediate REPL connect")

local expected = {
  clojure = true,
  fennel = true,
  python = true,
}

for _, ft in ipairs(configured_filetypes) do
  assert(expected[ft], ("unexpected Conjure filetype configured: %s"):format(ft))
  expected[ft] = nil
end

for ft in pairs(expected) do
  error(("missing expected Conjure filetype: %s"):format(ft))
end

local bufnr = vim.api.nvim_get_current_buf()

vim.api.nvim_buf_set_name(bufnr, "/tmp/project/src/core.clj")
vim.bo[bufnr].filetype = "clojure"
vim.api.nvim_exec_autocmds("FileType", {
  buffer = bufnr,
  modeline = false,
})

assert(type(deferred_callback) == "function", "expected Conjure to schedule deferred REPL connect for Clojure")
assert(type(deferred_delay) == "number" and deferred_delay > 0, "expected deferred REPL connect to use a positive delay")
assert(connect_calls == 0, "expected deferred REPL connect to avoid running during FileType autocmd")

deferred_callback()

assert(connect_calls == 1, "expected deferred REPL connect callback to call connect-port-file()")
assert(type(last_connect_opts) == "table", "expected deferred REPL connect callback to pass options to connect-port-file()")
assert(last_connect_opts["silent?"] == true, "expected deferred REPL connect callback to avoid Conjure auto-REPL fallback")

deferred_callback = nil
local same_root_bufnr = vim.api.nvim_create_buf(false, true)

vim.api.nvim_buf_set_name(same_root_bufnr, "/tmp/project/test/core_test.clj")
vim.bo[same_root_bufnr].filetype = "clojure"
vim.api.nvim_exec_autocmds("FileType", {
  buffer = same_root_bufnr,
  modeline = false,
})

assert(deferred_callback == nil, "expected deferred REPL connect to avoid rescheduling for the same root")

local other_root_bufnr = vim.api.nvim_create_buf(false, true)

vim.api.nvim_buf_set_name(other_root_bufnr, "/tmp/other-project/src/core.clj")
vim.bo[other_root_bufnr].filetype = "clojure"
vim.api.nvim_exec_autocmds("FileType", {
  buffer = other_root_bufnr,
  modeline = false,
})

assert(type(deferred_callback) == "function", "expected deferred REPL connect to schedule for a different root")

vim.defer_fn = original_defer_fn
vim.fs.root = original_fs_root
package.loaded["conjure.client.clojure.nrepl.action"] = original_action
package.preload["conjure.client.clojure.nrepl.action"] = original_action_preload
