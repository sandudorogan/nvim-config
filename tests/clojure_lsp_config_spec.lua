local function load_config_with_stubs()
  local original_env_java_home = vim.env.JAVA_HOME
  local original_system = vim.system
  local original_executable = vim.fn.executable

  vim.env.JAVA_HOME = nil

  local wait_called = false
  local system_calls = {}

  vim.fn.executable = function(binary)
    if binary == "/usr/libexec/java_home" then
      return 1
    end

    return original_executable(binary)
  end

  vim.system = function(cmd, opts, on_exit)
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
  end

  local ok, result = pcall(function()
    return dofile(vim.fn.getcwd() .. "/lsp/clojure_lsp.lua")
  end)

  vim.env.JAVA_HOME = original_env_java_home
  vim.system = original_system
  vim.fn.executable = original_executable

  assert(ok, result)

  return result, system_calls, wait_called
end

local config, system_calls, wait_called = load_config_with_stubs()

assert(type(config.root_dir) == "function", "expected clojure_lsp root_dir to be a function")
assert(type(config.before_init) == "function", "expected clojure_lsp before_init to be configured")
assert(wait_called == false, "expected clojure_lsp config load to avoid synchronous wait()")
assert(#system_calls == 0, "expected clojure_lsp config load to avoid starting java_home lookup eagerly")
