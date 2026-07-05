return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    rename = {},
    words = { enabled = false },
  },
  keys = {
    {
      "<leader>fn",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename file",
    },
  },
}
