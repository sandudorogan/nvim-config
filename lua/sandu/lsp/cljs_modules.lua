local api = vim.api
local fn = vim.fn
local uv = vim.uv

local M = {}

local function read_file(path)
  local fd = uv.fs_open(path, "r", 438)
  if not fd then
    return nil
  end

  local stat = uv.fs_fstat(fd)
  local data = stat and uv.fs_read(fd, stat.size, 0) or nil
  uv.fs_close(fd)

  return data
end

local function file_exists(path)
  local stat = path and uv.fs_stat(path) or nil
  return stat and stat.type == "file" or false
end

local function dir_exists(path)
  local stat = path and uv.fs_stat(path) or nil
  return stat and stat.type == "directory" or false
end

local function escape_lua_pattern(text)
  return (text:gsub("([^%w])", "%%%1"))
end

local function current_symbol()
  return fn.expand("<cword>")
end

local function buf_path(bufnr)
  local name = api.nvim_buf_get_name(bufnr)
  return name ~= "" and name or nil
end

local function ns_form(bufnr)
  local lines = api.nvim_buf_get_lines(bufnr, 0, math.min(api.nvim_buf_line_count(bufnr), 200), false)
  local source = table.concat(lines, "\n")
  local start_index = source:find("%(ns[%s%[]")

  if not start_index then
    return nil
  end

  local depth = 0
  local in_string = false
  local escaped = false

  for i = start_index, #source do
    local char = source:sub(i, i)

    if in_string then
      if escaped then
        escaped = false
      elseif char == "\\" then
        escaped = true
      elseif char == '"' then
        in_string = false
      end
    else
      if char == '"' then
        in_string = true
      elseif char == "(" then
        depth = depth + 1
      elseif char == ")" then
        depth = depth - 1
        if depth == 0 then
          return source:sub(start_index, i)
        end
      end
    end
  end

  return nil
end

local function js_imports(bufnr)
  local imports = {}
  local form = ns_form(bufnr)

  if not form then
    return imports
  end

  for vector in form:gmatch("%b[]") do
    local module_name = vector:match('%["([^"]+)"')
    if module_name then
      local alias = vector:match(":as%s+([%w%-%._/]+)")
      local refer_body = vector:match(":refer%s+%[([^%]]+)%]")

      if alias then
        imports[alias] = { module = module_name, kind = "alias" }
      end

      if refer_body then
        for symbol in refer_body:gmatch("[^%s,%[%]]+") do
          imports[symbol] = { module = module_name, kind = "refer" }
        end
      end
    end
  end

  return imports
end

local function find_package_dir(path, package_name)
  local dir = vim.fs.dirname(path)

  while dir and dir ~= "" do
    local candidate = vim.fs.joinpath(dir, "node_modules", package_name)
    if dir_exists(candidate) then
      return candidate
    end

    local parent = vim.fs.dirname(dir)
    if not parent or parent == dir then
      break
    end
    dir = parent
  end

  return nil
end

local function decode_package_json(package_dir)
  local package_json = read_file(vim.fs.joinpath(package_dir, "package.json"))
  if not package_json then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, package_json)
  return ok and decoded or nil
end

local function resolve_candidate(base_dir, candidate)
  if not candidate or candidate == "" then
    return nil
  end

  local normalized = candidate:gsub("^%./", "")
  local with_base = vim.fs.joinpath(base_dir, normalized)
  local stem = with_base:gsub("%.[^.]+$", "")
  local candidates = {
    with_base,
    stem .. ".d.ts",
    stem .. ".ts",
    stem .. ".tsx",
    stem .. ".js",
    stem .. ".jsx",
    stem .. ".mjs",
    vim.fs.joinpath(with_base, "index.d.ts"),
    vim.fs.joinpath(with_base, "index.ts"),
    vim.fs.joinpath(with_base, "index.tsx"),
    vim.fs.joinpath(with_base, "index.js"),
    vim.fs.joinpath(with_base, "index.jsx"),
    vim.fs.joinpath(with_base, "index.mjs"),
  }

  for _, path in ipairs(candidates) do
    if file_exists(path) then
      return path
    end
  end

  return nil
end

local function package_entry(package_dir)
  local package_json = decode_package_json(package_dir)
  if not package_json then
    return nil
  end

  local candidates = {
    package_json.source,
    package_json.types,
    package_json.main,
  }

  local exports = package_json.exports
  if type(exports) == "table" then
    local root_export = exports["."] or exports
    if type(root_export) == "string" then
      table.insert(candidates, root_export)
    elseif type(root_export) == "table" then
      for _, key in ipairs({ "types", "browser", "development", "default", "import", "require" }) do
        table.insert(candidates, root_export[key])
      end
    end
  end

  for _, candidate in ipairs(candidates) do
    local resolved = resolve_candidate(package_dir, candidate)
    if resolved then
      return resolved
    end
  end

  return nil
end

local function symbol_score(path, line, symbol)
  local score = 0
  local escaped = escape_lua_pattern(symbol)
  local basename = vim.fs.basename(path)

  if basename == symbol .. ".d.ts" then
    score = score + 700
  elseif basename == symbol .. ".ts" or basename == symbol .. ".tsx" then
    score = score + 650
  elseif basename == symbol .. ".js" or basename == symbol .. ".jsx" or basename == symbol .. ".mjs" then
    score = score + 600
  end

  if path:find("/src/", 1, true) then
    score = score + 250
  end
  if path:find("/dist/declarations/", 1, true) then
    score = score + 225
  end
  if path:find("/dist/", 1, true) then
    score = score + 150
  end

  if line:match("export%s+declare%s+const%s+" .. escaped) then
    score = score + 600
  elseif line:match("export%s+interface%s+" .. escaped) then
    score = score + 575
  elseif line:match("export%s+type%s+" .. escaped .. "%s*=") then
    score = score + 575
  elseif line:match("export%s+function%s+" .. escaped) then
    score = score + 550
  elseif line:match("export%s+const%s+" .. escaped .. "%s*=") then
    score = score + 550
  elseif line:match("export%s+class%s+" .. escaped) then
    score = score + 550
  elseif line:match("declare%s+const%s+" .. escaped) then
    score = score + 500
  elseif line:match("function%s+" .. escaped) then
    score = score + 475
  elseif line:match("const%s+" .. escaped .. "%s*=") then
    score = score + 475
  elseif line:match("class%s+" .. escaped) then
    score = score + 475
  elseif line:match("export%s+{.-" .. escaped .. ".-}%s+from%s+") then
    score = score + 375
  elseif line:match("export%s+{.-" .. escaped .. ".-}") then
    score = score + 300
  elseif line:match("import%s+{.-" .. escaped .. ".-}%s+from%s+") then
    score = score + 175
  end

  return score
end

local function search_package_symbol(package_dir, symbol)
  if fn.executable("rg") ~= 1 then
    return {}
  end

  local cmd = {
    "rg",
    "--no-heading",
    "--color",
    "never",
    "--line-number",
    "--column",
    "--fixed-strings",
    symbol,
    package_dir,
    "--glob",
    "*.d.ts",
    "--glob",
    "*.ts",
    "--glob",
    "*.tsx",
    "--glob",
    "*.js",
    "--glob",
    "*.jsx",
    "--glob",
    "*.mjs",
  }

  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 or not result.stdout or result.stdout == "" then
    return {}
  end

  local locations = {}
  for _, raw_line in ipairs(vim.split(result.stdout, "\n", { trimempty = true })) do
    local path, lnum, col, text = raw_line:match("^(.-):(%d+):(%d+):(.*)$")
    if path and text then
      table.insert(locations, {
        filename = path,
        lnum = tonumber(lnum),
        col = tonumber(col),
        text = text,
        score = symbol_score(path, text, symbol),
      })
    end
  end

  table.sort(locations, function(left, right)
    if left.score ~= right.score then
      return left.score > right.score
    end
    if left.filename ~= right.filename then
      return left.filename < right.filename
    end
    return left.lnum < right.lnum
  end)

  local deduped = {}
  local seen = {}
  for _, location in ipairs(locations) do
    local key = table.concat({ location.filename, location.lnum, location.col }, ":")
    if not seen[key] then
      seen[key] = true
      table.insert(deduped, location)
    end
  end

  return deduped
end

local function package_locations(path, import, symbol)
  local package_dir = find_package_dir(path, import.module)
  if not package_dir then
    return {}
  end

  if import.kind == "alias" then
    local entry = package_entry(package_dir)
    if not entry then
      return {}
    end

    return {
      {
        filename = entry,
        lnum = 1,
        col = 1,
        text = import.module,
        score = 1,
      },
    }
  end

  return search_package_symbol(package_dir, symbol)
end

function M.find_locations(bufnr, symbol)
  bufnr = bufnr == 0 and api.nvim_get_current_buf() or bufnr
  symbol = symbol or current_symbol()

  if not bufnr or not symbol or symbol == "" then
    return {}
  end

  local path = buf_path(bufnr)
  if not path then
    return {}
  end

  local import = js_imports(bufnr)[symbol]
  if not import then
    return {}
  end

  return package_locations(path, import, symbol)
end

local function clamp_cursor(bufnr, row, col)
  local line_count = api.nvim_buf_line_count(bufnr)
  if line_count == 0 then
    return { 1, 0 }
  end

  local clamped_row = math.max(1, math.min(row, line_count))
  local line = api.nvim_buf_get_lines(bufnr, clamped_row - 1, clamped_row, false)[1] or ""
  local clamped_col = math.max(0, math.min(col, #line))

  return { clamped_row, clamped_col }
end

local function jump_to_item(item)
  vim.cmd("normal! m'")
  fn.settagstack(fn.win_getid(), {
    items = {
      {
        tagname = current_symbol(),
        from = { fn.bufnr("%"), fn.line("."), fn.col("."), 0 },
      },
    },
  }, "t")

  local bufnr = item.bufnr or fn.bufadd(item.filename)
  vim.bo[bufnr].buflisted = true
  api.nvim_win_set_buf(0, bufnr)
  api.nvim_win_set_cursor(0, clamp_cursor(bufnr, item.lnum, math.max(item.col - 1, 0)))
  vim.cmd("normal! zv")
end

function M.jump(bufnr, symbol)
  local locations = M.find_locations(bufnr, symbol)

  if vim.tbl_isempty(locations) then
    return false
  end

  if #locations == 1 then
    jump_to_item(locations[1])
    return true
  end

  fn.setloclist(0, {}, " ", {
    title = "CLJS module definitions",
    items = locations,
  })

  local ok, telescope = pcall(require, "telescope.builtin")
  if ok and telescope.loclist then
    telescope.loclist({
      previewer = true,
      layout_strategy = "vertical",
      layout_config = {
        width = 0.95,
        height = 0.95,
        preview_cutoff = 1,
        preview_height = 0.6,
      },
    })
  else
    vim.cmd.lopen()
  end

  return true
end

return M
