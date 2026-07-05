local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

local real_executable = vim.fn.executable

local wait_called = false
local system_calls = {}

t.patch(vim.env, "JAVA_HOME", nil)

t.patch(vim.fn, "executable", function(binary)
  if binary == "/usr/libexec/java_home" then
    return 1
  end

  return real_executable(binary)
end)

t.patch(vim, "system", function(cmd, opts, on_exit)
  table.insert(system_calls, {
    cmd = cmd,
    opts = opts,
    on_exit = on_exit,
  })

  return {
    wait = function()
      wait_called = true
      error("wait() should not be called while loading the clojure_lsp config")
    end,
  }
end)

t.run(function()
  local config = t.load("lsp/clojure_lsp.lua")

  assert(vim.deep_equal(config.cmd, { "clojure-lsp" }), "expected clojure_lsp cmd to be configured")
  assert(vim.tbl_contains(config.filetypes, "clojure"), "expected clojure_lsp to attach to clojure files")
  assert(vim.tbl_contains(config.filetypes, "edn"), "expected clojure_lsp to attach to edn files")
  assert(type(config.root_dir) == "function", "expected clojure_lsp root_dir to be a function")
  assert(type(config.before_init) == "function", "expected clojure_lsp before_init to be configured")
  assert(wait_called == false, "expected clojure_lsp config load to avoid synchronous wait()")
  assert(#system_calls == 0, "expected clojure_lsp config load to avoid starting java_home lookup eagerly")
end)
