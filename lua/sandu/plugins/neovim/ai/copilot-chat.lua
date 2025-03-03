local prompts = {
  -- Code related prompts
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please explain how the selected code works, then generate unit tests for it.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
  SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
  -- Text related prompts
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",
}

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- version = "v3.3.0", -- Use a specific version to prevent breaking changes
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- Use Copilot.vim for the chat
      { "nvim-telescope/telescope.nvim" }, -- Use telescope for help actions
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      debug = false, -- Enable debugging
      model = "claude-3.7-sonnet",
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      prompts = prompts,
      auto_follow_cursor = false, -- Don't follow the cursor after getting response
      mappings = {
        -- Use tab for completion
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },
        -- Close the chat
        close = {
          normal = "q",
          insert = "<C-c>",
        },
        -- Reset the chat buffer
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
        -- Submit the prompt to Copilot
        submit_prompt = {
          normal = "<CR>",
          insert = "<C-CR>",
        },
        -- Accept the diff
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },
        -- Show help
        show_help = {
          normal = "g?",
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")

      -- Setup with options
      chat.setup(opts)

      -- Define custom commands
      local function create_command(name, selection_type, window_opts)
        vim.api.nvim_create_user_command("CopilotChat" .. name, function(args)
          local options = { selection = selection_type }
          if window_opts then
            options.window = window_opts
          end
          chat.ask(args.args, options)
        end, { nargs = "*", range = true })
      end

      -- Create commands with different selection types
      create_command("Visual", select.visual)
      create_command("Buffer", select.buffer)

      -- Create inline chat command with custom window layout
      create_command("Inline", select.visual, {
        layout = "float",
        relative = "cursor",
        width = 1,
        height = 0.4,
        row = 1,
      })

      -- Custom buffer styling for Copilot buffers
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          -- Set filetype to markdown for improved syntax highlighting
          if vim.bo.filetype == "copilot-chat" then
            vim.bo.filetype = "markdown"
          end
        end,
      })
    end,
    event = "VeryLazy",
    init = function()
      require("which-key").add({
        { "<leader>ac", group = "CopilotChat" }, -- NOTE: add for avante.nvim
        -- Show prompts actions with telescope
        {
          "<leader>acp",
          function()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
          end,
          desc = "CopilotChat - Prompt actions",
        },
        {
          "<leader>acp",
          ":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>",
          mode = "x",
          desc = "CopilotChat - Prompt actions",
        },
        -- Code related commands
        { "<leader>ace", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
        { "<leader>act", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },
        { "<leader>acr", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },
        { "<leader>acR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },
        { "<leader>acn", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },
        -- Chat with Copilot in visual mode
        {
          "<leader>acv",
          ":CopilotChatVisual",
          mode = "x",
          desc = "CopilotChat - Open in vertical split",
        },
        {
          "<leader>acx",
          ":CopilotChatInline<cr>",
          mode = "x",
          desc = "CopilotChat - Inline chat",
        },
        -- Custom input for CopilotChat
        {
          "<leader>aci",
          function()
            local input = vim.fn.input("Ask Copilot: ")
            if input ~= "" then
              vim.cmd("CopilotChat " .. input)
            end
          end,
          desc = "CopilotChat - Ask input",
        },
        -- Generate commit message based on the git diff
        {
          "<leader>acm",
          "<cmd>CopilotChatCommit<cr>",
          desc = "CopilotChat - Generate commit message for all changes",
        },
        -- Quick chat with Copilot
        {
          "<leader>acq",
          function()
            local chat_input = vim.fn.input("Quick Chat: ")
            if chat_input ~= "" then
              vim.cmd("CopilotChatBuffer " .. chat_input)
            end
          end,
          desc = "CopilotChat - Quick chat",
        },
        -- Debug
        { "<leader>acd", "<cmd>CopilotChatDebugInfo<cr>", desc = "CopilotChat - Debug Info" },
        -- Fix the issue with diagnostic
        { "<leader>acf", "<cmd>CopilotChatFixDiagnostic<cr>", desc = "CopilotChat - Fix Diagnostic" },
        -- Clear buffer and chat history
        { "<leader>acl", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
        -- Toggle Copilot Chat Vsplit
        { "<leader>acv", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
        -- Copilot Chat Models
        { "<leader>ac?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },
        -- Copilot Chat Agents
        -- { "<leader>aa", "<cmd>CopilotChatAgents<cr>", desc = "CopilotChat - Select Agents" },
      })
    end,
  },
}
