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
    require("sandu.plugins.ai.codecompanion.fidget-spinner"):init()
    require("sandu.plugins.ai.codecompanion.lualine"):init()
  end,
  keys = {
    { "<leader>aa", ":CodeCompanionActions<CR>", desc = "Companion - 🎯 Open Action Palette" },
    { "<leader>ac", ":CodeCompanionChat<CR>", desc = "Companion - 💬 Open AI chat" },
    { "<leader>ax", ":CodeCompanionContext<CR>", desc = "Companion - 📄 Add file context" },
    { "<leader>as", ":CodeCompanionSelection<CR>", mode = "v", desc = "Companion - ✂️ Use selection as context" },
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-3.7-sonnet",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          slash_commands = require("sandu.plugins.ai.codecompanion.slash-commands"),
        },
      },
    })
  end,
}
