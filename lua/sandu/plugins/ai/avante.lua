return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- set this if you want to always pull the latest change
  enabled = true,
  opts = {
    -- add any opts here
    provider = "claude",
    auto_suggestions_provider = "openai",
    copilot = {
      model = "claude-3.7-sonnet",
    },
    claude = {
      model = "claude-3-7-sonnet-20250219",
    },
    openai = {
      model = "gpt-4o",
    },
    rag_service = {
      enabled = true, -- Enables the rag service, requires OPENAI_API_KEY to be set
    },
  },
  dual_boost = {
    enabled = true,
    first_provider = "copilot",
    second_provider = "claude",
    copilot = {
      model = "claude-3.7-sonnet",
    },
    claude = {
      model = "claude-3.7-sonnet-20250219",
    },
  },
  beheviour = {
    auto_suggestions = true,
    auto_suggestions_respect_ignore = true,
    auto_apply_diff_after_generation = true,
    enable_cursor_planning_mode = true, -- Whether to enable Cursor Planning Mode. Default to false.
  },
  suggestion = {
    debounce = 50,
    throttle = 50,
  },
  mappings = {
    suggestion = {
      accept = "<Tab>",
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  init = function()
    require("sandu.plugins.ai.avante.keymaps")
  end,
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
