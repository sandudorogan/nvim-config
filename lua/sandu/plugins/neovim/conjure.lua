return {
  {
    "Olical/conjure",
    ft = { "clojure", "fennel", "python" }, -- etc
    lazy = true,
    init = function()
      -- Set configuration options here
      vim.g["conjure#debug"] = false
    end,
  },
}
