return {
  "echasnovski/mini.pairs",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mini.pairs").setup()
  end,
}
