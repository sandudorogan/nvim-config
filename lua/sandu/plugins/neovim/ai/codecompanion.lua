return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "zbirenbaum/copilot.lua",
    "j-hui/fidget.nvim",
  },
  opts = {
    strategies = {
      chat = {
        adapter = "copilot",
      },
    },
    ui = {
      popup = {
        border = "rounded",
        width = 0.6,
        height = 0.6,
      },
    },
  },
  init = function()
    require("sandu.plugins.neovim.ai.codecompanion.fidget-spinner"):init()
    require("sandu.plugins.neovim.ai.codecompanion.lualine"):init()

    require("which-key").add({
      { "<leader>am", group = "🤖CodeCompanion" },
      { "<leader>amb", ":CodeCompanionActions<CR>", desc = "Companion - 🎯 Open Action Palette" },
      { "<leader>amc", ":CodeCompanionChat<CR>", desc = "Companion - 💬 Open AI chat" },
      { "<leader>amx", ":CodeCompanionContext<CR>", desc = "Companion - 📄 Add file context" },
      {
        "<leader>ams",
        ":CodeCompanionSelection<CR>",
        mode = "v",
        desc = "Companion - ✂️ Use selection as context",
      },
    })
  end,
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          slash_commands = require("sandu.plugins.neovim.ai.codecompanion.slash-commands"),
        },
      },
    })
  end,
}
