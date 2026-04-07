local lsp_packages = {
  "typescript-language-server",
  "html-lsp",
  "css-lsp",
  "tailwindcss-language-server",
  "svelte-language-server",
  "lua-language-server",
  "graphql-language-service-cli",
  "emmet-ls",
  "prisma-language-server",
  "pyright",
  "eslint-lsp",
}

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = vim.list_extend(vim.deepcopy(lsp_packages), {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "pylint",
        "eslint_d",
      }),
      integrations = {
        ["mason-nvim-dap"] = false,
      },
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    cond = function()
      return #vim.api.nvim_list_uis() > 0
    end,
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      ensure_installed = {
        "python",
        "js",
      },
      automatic_installation = true,
      handlers = {},
    },
  },
}
