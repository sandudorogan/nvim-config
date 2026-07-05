return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    dashboard = {
      preset = {
        keys = {
          { icon = " ", key = "e", desc = "New File", action = ":ene" },
          { icon = "󰱼 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "g", desc = "Find Word", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "x", desc = "Toggle File Explorer", action = ":lua Snacks.explorer()" },
          { icon = "󰁯 ", key = "s", desc = "Restore Session For Current Directory", action = ":SessionRestore" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit NVIM", action = ":qa" },
        },
      },
    },
    explorer = {},
    indent = {
      indent = { char = "┊" },
      scope = { char = "┊" },
    },
    picker = {
      actions = {
        -- lazy-require so trouble keeps its lazy loading
        trouble_open = function(...)
          return require("trouble.sources.snacks").actions.trouble_open.action(...)
        end,
      },
      win = {
        input = {
          keys = {
            ["<c-t>"] = { "trouble_open", mode = { "i", "n" } },
          },
        },
      },
    },
    rename = {},
    words = { enabled = false },
  },
  keys = {
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Fuzzy find files in cwd" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Fuzzy find recent files" },
    { "<leader>fs", function() Snacks.picker.grep() end, desc = "Find string in cwd" },
    { "<leader>fc", function() Snacks.picker.grep_word() end, desc = "Find string under cursor in cwd" },
    -- load todo-comments first so it registers its picker source
    { "<leader>ft", function() require("todo-comments") Snacks.picker.todo_comments() end, desc = "Find todos" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Find keymaps" },
    { "<leader>fa", function() Snacks.picker.lsp_symbols() end, desc = "Find symbols" },
    { "<leader>ee", function() Snacks.explorer() end, desc = "Toggle file explorer" },
    { "<leader>ef", function() Snacks.explorer.reveal() end, desc = "Open file explorer on current file" },
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Open lazy git" },
    { "<leader>ld", function() Snacks.terminal("lazydocker") end, desc = "Open Lazydocker floating window" },
    { "<leader>sm", function() Snacks.zen.zoom() end, desc = "Maximize/minimize split" },
    { "<leader>fn", function() Snacks.rename.rename_file() end, desc = "Rename file" },
  },
}
