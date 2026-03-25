return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>g", group = "git" },
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,
    },
    keys = {
      { "<leader>go", "<cmd>DiffviewOpen<CR>", desc = "Open git diff" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close git diff" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "Current file history" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<CR>", desc = "Repo file history" },
    },
  },
}
