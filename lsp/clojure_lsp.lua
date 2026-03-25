local java_home = vim.env.JAVA_HOME

if (not java_home or java_home == "") and vim.fn.executable("/usr/libexec/java_home") == 1 then
  local result = vim.system({ "/usr/libexec/java_home" }, { text = true }):wait()
  if result.code == 0 and result.stdout then
    java_home = result.stdout:gsub("%s+$", "")
  end
end

return {
  root_markers = { ".git", "deps.edn", "project.clj", "shadow-cljs.edn", "bb.edn" },
  init_options = {
    ["dependency-scheme"] = "jar",
    java = vim.tbl_extend("keep", {
      ["decompile-jar-as-project?"] = true,
    }, java_home and java_home ~= "" and { ["home-path"] = java_home } or {}),
  },
}
