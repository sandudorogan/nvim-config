package.path = table.concat({
  vim.fn.getcwd() .. "/lua/?.lua",
  vim.fn.getcwd() .. "/lua/?/init.lua",
  package.path,
}, ";")

local spec = dofile(vim.fn.getcwd() .. "/lua/sandu/plugins/neovim/conjure.lua")
local conjure = spec[1]

assert(type(conjure.init) == "function", "expected conjure plugin spec to expose init()")

conjure.init()

local configured_filetypes = vim.g["conjure#filetypes"]

assert(type(configured_filetypes) == "table", "expected g:conjure#filetypes to be configured")

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
