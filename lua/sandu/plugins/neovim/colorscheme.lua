return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato",
      custom_highlights = function(colors)
        return {
          ["@variable.clojure"] = { fg = colors.lavender },
        }
      end,
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        mason = true,
        snacks = { enabled = true },
        treesitter = true,
      },
    })

    vim.cmd.colorscheme("catppuccin")
  end,
}
