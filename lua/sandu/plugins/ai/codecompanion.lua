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
          slash_commands = {
            ["git_files"] = {
              description = "List git files",
              ---@param chat CodeCompanion.Chat
              callback = function(chat)
                local handle = io.popen("git ls-files")
                if handle ~= nil then
                  local result = handle:read("*a")
                  handle:close()
                  chat:add_reference({ content = result }, "git_files", "<git_files>")
                else
                  return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
              end,
              opts = {
                contains_code = false,
              },
            },
            ["git_status"] = {
              description = "See git status",
              ---@param chat CodeCompanion.Chat
              callback = function(chat)
                local handle = io.popen("git status")
                if handle ~= nil then
                  local result = handle:read("*a")
                  handle:close()

                  if result and result ~= "" then
                    chat:add_reference({ content = result }, "git_status", "<git_status>")
                  else
                    return vim.notify(
                      "No changes detected in git diff",
                      vim.log.levels.INFO,
                      { title = "CodeCompanion" }
                    )
                  end
                else
                  return vim.notify("No git status available", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
              end,
              opts = {
                contains_code = true,
              },
            },
            ["git_diff"] = {
              description = "Staged changes",
              ---@param chat CodeCompanion.Chat
              callback = function(chat)
                local handle = io.popen("git diff --staged")
                if handle ~= nil then
                  local result = handle:read("*a")
                  handle:close()

                  if result and result ~= "" then
                    chat:add_reference({ content = result }, "git_diff", "<git_diff>")
                  else
                    return vim.notify(
                      "No changes detected in git diff",
                      vim.log.levels.INFO,
                      { title = "CodeCompanion" }
                    )
                  end
                else
                  return vim.notify("Failed to run git diff command", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
              end,
            },
          },
        },
      },
    })
  end,
}
