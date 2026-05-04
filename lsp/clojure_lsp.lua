local root_markers = { "deps.edn", "project.clj", "shadow-cljs.edn", "bb.edn", ".git" }

local function java_home()
  if vim.env.JAVA_HOME and vim.env.JAVA_HOME ~= "" then
    return vim.env.JAVA_HOME
  end

  if vim.fn.executable("/usr/libexec/java_home") ~= 1 then
    return nil
  end

  local result = vim.system({ "/usr/libexec/java_home" }, { text = true }):wait()
  if result.code ~= 0 or not result.stdout then
    return nil
  end

  return result.stdout:gsub("%s+$", "")
end

return {
  cmd = { "clojure-lsp" },
  filetypes = { "clojure", "edn" },
  root_markers = root_markers,
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, root_markers))
  end,
  init_options = {
    ["dependency-scheme"] = "jar",
    java = {
      ["decompile-jar-as-project?"] = true,
    },
  },
  before_init = function(_, config)
    local home = java_home()
    if home and home ~= "" then
      config.init_options = config.init_options or {}
      config.init_options.java = vim.tbl_extend("keep", config.init_options.java or {}, {
        ["home-path"] = home,
      })
    end
  end,
}
