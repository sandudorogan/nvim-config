return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      integrations = {
        cmp = true,
        gitsigns = true,
        mason = true,
        telescope = true,
        treesitter = true,
      },
    })

    vim.cmd.colorscheme("catppuccin")
    vim.api.nvim_set_hl(0, "@variable.clojure", { link = "@variable.parameter" })
  end,
}
