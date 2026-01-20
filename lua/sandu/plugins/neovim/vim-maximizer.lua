return {
  "declancm/maximize.nvim",
  keys = {
    { "<leader>sm", function() require("maximize").toggle() end, desc = "Maximize/minimize split" },
  },
  config = true,
}
