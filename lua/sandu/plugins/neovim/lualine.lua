return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "AndreM222/copilot-lualine",
    "catppuccin/nvim",
  },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count
    local function attached_lsp_names()
      local names = {}
      local seen = {}

      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client.name and not seen[client.name] then
          seen[client.name] = true
          table.insert(names, client.name)
        end
      end

      return names
    end

    lualine.setup({
      options = {
        theme = "catppuccin-macchiato",
      },
      sections = {
        lualine_b = { "diagnostics" },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          {
            function()
              return " " .. table.concat(attached_lsp_names(), ", ")
            end,
            cond = function()
              return #attached_lsp_names() > 0
            end,
          },
          { "copilot" },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
    })
  end,
}
