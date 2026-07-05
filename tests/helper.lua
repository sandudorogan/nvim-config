package.path = table.concat({
  vim.fn.getcwd() .. "/lua/?.lua",
  vim.fn.getcwd() .. "/lua/?/init.lua",
  package.path,
}, ";")

local M = {}

local patches = {}

function M.patch(tbl, key, value)
  table.insert(patches, { tbl = tbl, key = key, original = tbl[key] })
  tbl[key] = value
end

function M.stub_module(name, mod)
  M.patch(package.loaded, name, nil)
  M.patch(package.preload, name, mod ~= nil and function()
    return mod
  end or nil)
end

function M.load(relative_path)
  return dofile(vim.fs.joinpath(vim.fn.getcwd(), relative_path))
end

function M.run(test)
  local ok, err = xpcall(test, debug.traceback)

  for i = #patches, 1, -1 do
    local patch = patches[i]
    patch.tbl[patch.key] = patch.original
  end
  patches = {}

  assert(ok, err)
end

return M
