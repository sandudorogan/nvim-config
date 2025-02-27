return {
  "echasnovski/mini.hipatterns",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mini.hipatterns").setup()
  end,
}
