return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = false,
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
