return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = true,
  enabled = true,
  opts = {
    -- Main configuration
    provider = "copilot",
    auto_suggestions_provider = "openai",
    cursor_applying_provider = "groq",

    -- Provider configurations
    copilot = {
      model = "claude-3.7-sonnet",
    },
    claude = {
      model = "claude-3-7-sonnet-20250219",
    },
    openai = {
      model = "o3-mini",
    },

    -- Dual boost setup
    dual_boost = {
      enabled = true,
      first_provider = "copilot",
      second_provider = "claude",
      providers = {
        copilot = {
          model = "claude-3.7-sonnet",
        },
        openai = {
          model = "o3-mini",
        },
        claude = {
          model = "claude-3.7-sonnet-20250219",
        },
      },
    },

    -- RAG service
    rag_service = {
      enabled = false,
      host_mount = os.getenv("HOME") .. "/workdir",
      llm_model = "o3-mini", -- The LLM model to use for RAG service
      embed_model = "o3-mini", -- The embedding model to use for RAG service
    },

    -- Behavior settings
    behaviour = {
      auto_suggestions = false,
      auto_suggestions_respect_ignore = true,
      auto_apply_diff_after_generation = true,
      enable_cursor_planning_mode = true,
    },

    -- UI and interaction
    suggestion = {
      debounce = 200,
      throttle = 200,
    },

    -- Keymaps
    mappings = {
      suggestion = {
        accept = "<Tab>",
      },
    },

    -- Additional providers
    vendors = {
      groq = {
        __inherited_from = "openai",
        api_key_name = "GROQ_API_KEY",
        endpoint = "https://api.groq.com/openai/v1/",
        model = "llama-3.3-70b-versatile",
        max_tokens = 32768,
      },
    },
  },

  build = "make",
  -- For Windows: build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"

  init = function()
    require("sandu.plugins.neovim.ai.avante.keymaps")
  end,

  dependencies = {
    -- Core dependencies
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",

    -- Provider dependencies
    "zbirenbaum/copilot.lua",
    "nvim-tree/nvim-web-devicons",

    -- Additional features
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
