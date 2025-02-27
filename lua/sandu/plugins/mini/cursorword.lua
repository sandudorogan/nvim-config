return {
  "echasnovski/mini.cursorword",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mini.cursorword").setup()
  end,
}
