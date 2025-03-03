return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "folke/trouble.nvim",
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({
        -- even more opts
      }),

      -- pseudo code / specification for writing custom displays, like the one
      -- for "codeactions"
      -- specific_opts = {
      --   [kind] = {
      --     make_indexed = function(items) -> indexed_items, width,
      --     make_displayer = function(widths) -> displayer
      --     make_display = function(displayer) -> function(e)
      --     make_ordinal = function(e) -> string
      --   },
      --   -- for example to disable the custom builtin "codeactions" display
      --      do the following
      --   codeactions = false,
      -- }
    },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        path_display = { "filename_first" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ff", function()
      builtin.find_files({ hidden = true })
    end, { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", function()
      builtin.oldfiles({ hidden = true })
    end, { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fs", function()
      builtin.live_grep({ additional_args = { "--hidden" } })
    end, { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fc", function()
      builtin.grep_string({ hidden = true })
    end, { desc = "Find string under cursor in cwd" })
    keymap.set(
      "n",
      "<leader>fh",
      builtin.help_tags,
      { desc = "Lists available help tags and opens a new window with the relevant help info" }
    )
    keymap.set("n", "<leader>fm", builtin.man_pages, { desc = "Lists manpage entries, opens them in a help window" })
    keymap.set("n", "<leader>fl", builtin.reloader, { desc = "Lists lua modules and reloads them" })
    keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Lists open buffers" })
    keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "Lists quickfix entries" })
    keymap.set("n", "<leader>ft", builtin.treesitter, { desc = "Lists tags" })
    keymap.set("n", "<leader>fo", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
  end,
}
