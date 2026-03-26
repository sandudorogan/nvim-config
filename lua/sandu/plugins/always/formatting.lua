return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")
    local zprint_path = vim.fn.exepath("zprint")
    local has_clojure_zprint = zprint_path ~= "" and zprint_path ~= "/usr/bin/zprint"
    local formatters = {}
    local formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      svelte = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      graphql = { "prettier" },
      liquid = { "prettier" },
      lua = { "stylua" },
      python = { "isort", "black" },
    }

    -- macOS ships an unrelated `/usr/bin/zprint` utility that dumps VM zone stats.
    if has_clojure_zprint then
      formatters.zprint = {
        command = zprint_path,
      }
      formatters_by_ft.clojure = { "zprint" }
    end

    conform.setup({
      formatters = formatters,
      formatters_by_ft = formatters_by_ft,
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
