return {
  "saghen/blink.cmp",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/lazydev.nvim", opts = {} },
    { "Saghen/blink.compat", version = "*", lazy = true, opts = {} },
    { "PaterJason/cmp-conjure", ft = { "clojure", "fennel" } },
    "rafamadriz/friendly-snippets",
  },
  version = "1.*",
  opts = {
    keymap = {
      preset = "default",
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<C-Space>"] = { "show", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    completion = {
      documentation = { auto_show = true },
      menu = {
        draw = {
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "lazydev" },
      per_filetype = {
        clojure = { inherit_defaults = true, "conjure" },
        fennel = { inherit_defaults = true, "conjure" },
      },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
        conjure = {
          name = "conjure",
          module = "blink.compat.source",
          score_offset = 90,
        },
      },
    },
    appearance = {
      kind_icons = {
        Text = "󰉿",
        Method = "󰊕",
        Function = "󰊕",
        Constructor = "",
        Field = "󰜢",
        Variable = "󰀫",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "󰑭",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "󰈇",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "󰙅",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "",
      },
    },
  },
  config = function(_, opts)
    local blink = require("blink.cmp")
    blink.setup(opts)

    -- Set capabilities for LSP
    vim.lsp.config("*", {
      capabilities = blink.get_lsp_capabilities(),
    })
  end,
}
