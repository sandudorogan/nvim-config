return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    backends = { "treesitter", "lsp" },
    layout = {
      max_width = { 40, 0.2 },
      min_width = 30,
      default_direction = "right",
    },
    show_guides = true,
    on_attach = function(bufnr)
      vim.keymap.set("n", "[a", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Prev aerial symbol" })
      vim.keymap.set("n", "]a", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next aerial symbol" })
    end,
  },
  keys = {
    { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "Toggle code outline" },
  },
}
