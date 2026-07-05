local t = dofile(vim.fn.getcwd() .. "/tests/helper.lua")

local real_exepath = vim.fn.exepath

local function load_setup_with_zprint_path(zprint_path)
  local captured = {}

  t.stub_module("conform", {
    setup = function(opts)
      captured.setup = opts
    end,
    format = function(opts)
      captured.last_format = opts
    end,
  })

  t.patch(vim.fn, "exepath", function(binary)
    if binary == "zprint" then
      return zprint_path
    end

    return real_exepath(binary)
  end)

  t.patch(vim.keymap, "set", function(...)
    captured.keymap = { ... }
  end)

  local spec = t.load("lua/sandu/plugins/always/formatting.lua")

  assert(type(spec.config) == "function", "expected formatting plugin spec to expose config()")

  spec.config()

  return captured.setup
end

t.run(function()
  local macos_setup = load_setup_with_zprint_path("/usr/bin/zprint")

  assert(macos_setup.formatters.zprint == nil, "expected macOS system zprint to be ignored")
  assert(
    macos_setup.formatters_by_ft.clojure == nil,
    "expected Clojure formatter mapping to be skipped when only `/usr/bin/zprint` is available"
  )

  local installed_setup = load_setup_with_zprint_path("/opt/homebrew/bin/zprint")

  assert(type(installed_setup.formatters.zprint) == "table", "expected user-installed zprint formatter config")
  assert(
    installed_setup.formatters.zprint.command == "/opt/homebrew/bin/zprint",
    "expected installed zprint path to be preserved"
  )
  assert(
    vim.deep_equal(installed_setup.formatters_by_ft.clojure, { "zprint" }),
    "expected Clojure to use zprint when a non-system binary is available"
  )
end)
