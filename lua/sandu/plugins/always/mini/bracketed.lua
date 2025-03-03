return {
  "echasnovski/mini.bracketed",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mini.bracketed").setup()
  end,
}
