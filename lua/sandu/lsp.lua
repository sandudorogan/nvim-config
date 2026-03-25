local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local cljs_modules = require("sandu.lsp.cljs_modules")
local lsp_util = vim.lsp.util

local clojure_dependency_group =
  api.nvim_create_augroup("ClojureLspDependencyBuffers", { clear = true })

local function is_uri(value)
  return type(value) == "string" and value:match("^%a[%w+.-]*:")
end

local function is_non_file_uri(uri)
  return is_uri(uri) and not vim.startswith(uri, "file:")
end

local function dependency_uri(uri)
  if type(uri) ~= "string" then
    return nil
  end

  local jar_index = uri:find("jar:file:", 1, true)
  if jar_index then
    return uri:sub(jar_index)
  end

  local zipfile_index = uri:find("zipfile:", 1, true)
  if zipfile_index then
    return uri:sub(zipfile_index)
  end

  return nil
end

local function is_clojure_dependency_uri(uri)
  return dependency_uri(uri) ~= nil
end

local function uri_entry_name(uri)
  local raw_uri = dependency_uri(uri) or uri
  return raw_uri:match("!/(.+)$") or raw_uri:match("::(.+)$")
end

local function location_uri(location)
  return location.targetUri or location.uri
end

local function location_range(location)
  return location.range or location.targetSelectionRange
end

local function clojure_lsp_client(preferred_client_id)
  if preferred_client_id then
    local client = vim.lsp.get_client_by_id(preferred_client_id)
    if client and client.name == "clojure_lsp" then
      return client
    end
  end

  local clients = vim.lsp.get_clients({ name = "clojure_lsp" })
  return clients[1]
end

local function dependency_contents(result)
  if type(result) == "string" then
    return result
  end

  if type(result) ~= "table" then
    return nil
  end

  return result.contents
    or result.content
    or result["dependency-contents"]
    or result.text
    or result.value
end

local function request_dependency_contents(client, uri)
  local attempts = {
    { uri = uri },
    uri,
  }

  for _, params in ipairs(attempts) do
    local ok, response = pcall(client.request_sync, client, "clojure/dependencyContents", params, 10000)
    if ok and response and response.result then
      local contents = dependency_contents(response.result)
      if contents then
        return contents
      end
    end
  end

  return nil
end

local function apply_dependency_contents(bufnr, uri, contents)
  local normalized = contents:gsub("\r\n", "\n")
  local lines = vim.split(normalized, "\n", { plain = true })
  local entry_name = uri_entry_name(uri)
  local filetype = entry_name and vim.filetype.match({ filename = entry_name }) or nil

  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].buflisted = true
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].modified = false

  if filetype and filetype ~= "" then
    vim.bo[bufnr].filetype = filetype
  end
end

local function load_clojure_dependency_buffer(bufnr, uri)
  local raw_uri = dependency_uri(uri)

  if not raw_uri or vim.b[bufnr].clojure_dependency_loaded then
    return
  end

  local client = clojure_lsp_client(vim.b[bufnr].clojure_lsp_client_id)
  if not client then
    return
  end

  local contents = request_dependency_contents(client, raw_uri)
  if not contents then
    vim.notify("clojure-lsp returned no dependency contents for " .. raw_uri, vim.log.levels.WARN)
    return
  end

  apply_dependency_contents(bufnr, raw_uri, contents)
  vim.b[bufnr].clojure_dependency_loaded = true
end

api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = clojure_dependency_group,
  pattern = "*",
  callback = function(args)
    local name = api.nvim_buf_get_name(args.buf)
    if is_clojure_dependency_uri(name) then
      load_clojure_dependency_buffer(args.buf, name)
    end
  end,
})

local function ensure_uri_buffer_loaded(uri, client_id)
  local bufnr = vim.uri_to_bufnr(uri)

  if client_id then
    vim.b[bufnr].clojure_lsp_client_id = client_id
  end

  if fn.bufloaded(bufnr) == 0 then
    fn.bufload(bufnr)
  end

  if is_clojure_dependency_uri(uri) and not vim.b[bufnr].clojure_dependency_loaded then
    load_clojure_dependency_buffer(bufnr, uri)
  end

  return bufnr
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

local function jump_to_location(location, client)
  local uri = location_uri(location)
  if not uri then
    return
  end

  local range = location_range(location)
  local bufnr = is_non_file_uri(uri)
    and ensure_uri_buffer_loaded(uri, client.id)
    or vim.uri_to_bufnr(uri)

  vim.cmd("normal! m'")
  vim.fn.settagstack(vim.fn.win_getid(), {
    items = {
      {
        tagname = vim.fn.expand("<cword>"),
        from = { vim.fn.bufnr("%"), vim.fn.line("."), vim.fn.col("."), 0 },
      },
    },
  }, "t")

  vim.bo[bufnr].buflisted = true
  api.nvim_win_set_buf(0, bufnr)

  if not range then
    return
  end

  local row = range.start.line + 1
  local col = lsp_util._get_line_byte_from_position(bufnr, range.start, client.offset_encoding)
  api.nvim_win_set_cursor(0, clamp_cursor(bufnr, row, col))
  vim.cmd("normal! zv")
end

local function method_title(method)
  local labels = {
    ["textDocument/declaration"] = "declarations",
    ["textDocument/definition"] = "definitions",
    ["textDocument/implementation"] = "implementations",
    ["textDocument/typeDefinition"] = "type definitions",
  }

  return labels[method] or method
end

local function client_position_params()
  local win = api.nvim_get_current_win()

  return function(client)
    return lsp_util.make_position_params(win, client.offset_encoding)
  end
end

local function jump_request(method)
  return function()
    local bufnr = api.nvim_get_current_buf()

    vim.lsp.buf_request_all(bufnr, method, client_position_params(), function(results)
      local matches = {}
      local items = {}

      for client_id, response in pairs(results) do
        local result = response.result
        if result then
          local client = vim.lsp.get_client_by_id(client_id)
          local locations = vim.islist(result) and result or { result }

          if client and not vim.tbl_isempty(locations) then
            vim.list_extend(items, lsp_util.locations_to_items(locations, client.offset_encoding))

            for _, location in ipairs(locations) do
              table.insert(matches, { client = client, location = location })
            end
          end
        end
      end

      if vim.tbl_isempty(matches) then
        if method == "textDocument/definition" and cljs_modules.jump(bufnr) then
          return
        end

        vim.notify("No " .. method_title(method) .. " found", vim.log.levels.INFO)
        return
      end

      if #matches == 1 then
        jump_to_location(matches[1].location, matches[1].client)
        return
      end

      vim.fn.setloclist(0, {}, " ", {
        title = "LSP " .. method_title(method),
        items = items,
      })
      vim.cmd.lopen()
    end)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf, silent = true }

    -- set keybinds
    opts.desc = "Show LSP references"
    keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

    opts.desc = "Go to declaration"
    keymap.set("n", "gD", jump_request("textDocument/declaration"), opts)

    opts.desc = "Go to definition"
    keymap.set("n", "gd", jump_request("textDocument/definition"), opts)

    opts.desc = "Go to implementation"
    keymap.set("n", "gi", jump_request("textDocument/implementation"), opts)

    opts.desc = "Go to type definition"
    keymap.set("n", "gt", jump_request("textDocument/typeDefinition"), opts)

    opts.desc = "See available code actions"
    keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

    opts.desc = "Smart rename"
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

    opts.desc = "Show buffer diagnostics"
    keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

    opts.desc = "Show line diagnostics"
    keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

    opts.desc = "Go to previous diagnostic"
    keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts) -- jump to previous diagnostic in buffer
    --
    opts.desc = "Go to next diagnostic"
    keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts) -- jump to next diagnostic in buffer

    opts.desc = "Show documentation for what is under cursor"
    keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

    opts.desc = "Restart LSP"
    keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
  end,
})

vim.lsp.inlay_hint.enable(true)

local severity = vim.diagnostic.severity

vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [severity.ERROR] = " ",
      [severity.WARN] = " ",
      [severity.HINT] = "󰠠 ",
      [severity.INFO] = " ",
    },
  },
})

if vim.fn.executable("clojure-lsp") == 1 then
  vim.lsp.enable("clojure_lsp")
end
