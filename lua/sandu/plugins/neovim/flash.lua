return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>j", group = "jump" },
      },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = true,
        },
      },
    },
    keys = {
      {
        "<leader>jj",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x", "o" },
        desc = "Jump",
      },
      {
        "<leader>jt",
        function()
          require("flash").treesitter()
        end,
        mode = { "n", "x", "o" },
        desc = "Treesitter jump",
      },
      {
        "<leader>jr",
        function()
          require("flash").remote()
        end,
        mode = "o",
        desc = "Remote jump",
      },
      {
        "<leader>js",
        function()
          require("flash").treesitter_search()
        end,
        mode = { "o", "x" },
        desc = "Treesitter search",
      },
    },
  },
}
