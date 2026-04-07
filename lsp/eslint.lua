local lsp = vim.lsp

local eslint_config_files = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

local lockfile_markers = {
  "package-lock.json",
  "yarn.lock",
  "pnpm-lock.yaml",
  "bun.lockb",
  "bun.lock",
}

local project_root_markers = vim.fn.has("nvim-0.11.3") == 1
    and { lockfile_markers, { ".git" } }
  or vim.list_extend(vim.deepcopy(lockfile_markers), { ".git" })

local function readfile_contains(path, text)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return false
  end

  for _, line in ipairs(lines) do
    if line:find(text, 1, true) then
      return true
    end
  end

  return false
end

local function within_root(path, root)
  return path ~= nil and root ~= nil and vim.startswith(path, root .. "/")
end

return {
  cmd = { "vscode-eslint-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "svelte",
    "typescript",
    "typescriptreact",
  },
  workspace_required = true,
  root_dir = function(bufnr, on_dir)
    if vim.fs.root(bufnr, { "deno.json", "deno.jsonc", "deno.lock" }) then
      on_dir(nil)
      return
    end

    local project_root = vim.fs.root(bufnr, project_root_markers) or vim.fn.getcwd()
    local filename = vim.api.nvim_buf_get_name(bufnr)

    local eslint_config = vim.fs.find(eslint_config_files, {
      path = filename,
      type = "file",
      upward = true,
      limit = 1,
    })[1]

    if within_root(eslint_config, project_root) then
      on_dir(project_root)
      return
    end

    local package_json = vim.fs.find("package.json", {
      path = filename,
      type = "file",
      upward = true,
      limit = 1,
    })[1]

    if within_root(package_json, project_root) and readfile_contains(package_json, '"eslintConfig"') then
      on_dir(project_root)
      return
    end

    on_dir(nil)
  end,
  settings = {
    codeActionOnSave = {
      enable = false,
      mode = "all",
    },
    format = true,
    run = "onType",
    validate = "on",
    workingDirectory = { mode = "auto" },
  },
  before_init = function(_, config)
    local root_dir = config.root_dir

    if not root_dir then
      return
    end

    config.settings = config.settings or {}
    config.settings.workspaceFolder = {
      uri = root_dir,
      name = vim.fn.fnamemodify(root_dir, ":t"),
    }

    local pnp_cjs = root_dir .. "/.pnp.cjs"
    local pnp_js = root_dir .. "/.pnp.js"
    if type(config.cmd) == "table" and (vim.uv.fs_stat(pnp_cjs) or vim.uv.fs_stat(pnp_js)) then
      config.cmd = vim.list_extend({ "yarn", "exec" }, config.cmd)
    end
  end,
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspEslintFixAll", function()
      client:request_sync("workspace/executeCommand", {
        command = "eslint.applyAllFixes",
        arguments = {
          {
            uri = vim.uri_from_bufnr(bufnr),
            version = lsp.util.buf_versions[bufnr],
          },
        },
      }, nil, bufnr)
    end, {})
  end,
  handlers = {
    ["eslint/confirmESLintExecution"] = function(_, result)
      if result then
        return 4
      end

      return nil
    end,
    ["eslint/noLibrary"] = function()
      vim.notify("[vim.lsp] Unable to find ESLint library.", vim.log.levels.WARN)
      return {}
    end,
    ["eslint/openDoc"] = function(_, result)
      if result then
        vim.ui.open(result.url)
      end

      return {}
    end,
    ["eslint/probeFailed"] = function()
      vim.notify("[vim.lsp] ESLint probe failed.", vim.log.levels.WARN)
      return {}
    end,
  },
}
