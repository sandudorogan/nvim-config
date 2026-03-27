return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "zbirenbaum/copilot.lua",
    {
      "j-hui/fidget.nvim",
      opts = {
        notification = {
          override_vim_notify = true,
          window = {
            avoid = { "NvimTree" },
          },
        },
      },
      config = function(_, opts)
        require("fidget.integration.nvim-tree").options.enable = false
        require("fidget").setup(opts)
      end,
    },
  },
  init = function()
    require("sandu.plugins.neovim.ai.codecompanion.fidget-spinner"):init()

    require("which-key").add({
      { "<leader>am", group = "🤖CodeCompanion" },
      { "<leader>amb", ":CodeCompanionActions<CR>", desc = "Companion - 🎯 Open Action Palette" },
      { "<leader>amc", ":CodeCompanionChat<CR>", desc = "Companion - 💬 Open AI chat" },
      {
        "<leader>ams",
        ":CodeCompanionChat add<CR>",
        mode = "v",
        desc = "Companion - ✂️ Add selection to chat",
      },
    })
  end,
  config = function()
    require("codecompanion").setup({
      interactions = {
        chat = {
          adapter = "copilot",
          slash_commands = require("sandu.plugins.neovim.ai.codecompanion.slash-commands"),
        },
      },
      display = {
        chat = {
          window = {
            layout = "float",
            border = "rounded",
            width = 0.6,
            height = 0.6,
          },
        },
      },
    })
  end,
}
