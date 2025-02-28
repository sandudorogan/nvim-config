return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 50,
        keymap = {
          accept = "<Tab>",
        },
      },
      panel = {
        enabled = false,
        auto_refresh = true,
      },
    })
  end,
}
