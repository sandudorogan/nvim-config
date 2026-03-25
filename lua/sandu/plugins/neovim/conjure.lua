return {
  {
    "Olical/conjure",
    ft = { "clojure", "fennel", "python" }, -- etc
    lazy = true,
    init = function()
      vim.g["conjure#debug"] = false
      vim.g["conjure#filetypes"] = { "clojure", "fennel", "python" }
    end,
  },
}
