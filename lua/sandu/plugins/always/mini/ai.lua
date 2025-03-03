return {
  "echasnovski/mini.ai",
  version = false,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mini.ai").setup()
  end,
}
