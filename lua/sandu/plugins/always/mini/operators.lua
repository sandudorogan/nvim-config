return {
  "echasnovski/mini.operators",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mini.operators").setup()
  end,
}
