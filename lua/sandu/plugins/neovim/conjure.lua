return {
  {
    "Olical/conjure",
    ft = { "clojure", "fennel", "python" }, -- etc
    lazy = true,
    init = function()
      local auto_connect_group = vim.api.nvim_create_augroup("SanduConjureAutoConnect", { clear = true })
      local auto_connect_roots = {}
      local root_markers = { "deps.edn", "project.clj", "shadow-cljs.edn", "bb.edn", ".git" }

      local function root_key(bufnr)
        local root = vim.fs.root(bufnr, root_markers)

        if root then
          return root
        end

        local name = vim.api.nvim_buf_get_name(bufnr)

        if name == "" then
          return nil
        end

        return vim.fs.dirname(name)
      end

      vim.g["conjure#debug"] = false
      vim.g["conjure#client_on_load"] = false
      vim.g["conjure#filetypes"] = { "clojure", "fennel", "python" }

      vim.api.nvim_create_autocmd("FileType", {
        group = auto_connect_group,
        pattern = "clojure",
        callback = function(args)
          local key = root_key(args.buf)

          if not key or auto_connect_roots[key] then
            return
          end

          auto_connect_roots[key] = true

          vim.defer_fn(function()
            if not vim.api.nvim_buf_is_valid(args.buf) or vim.bo[args.buf].filetype ~= "clojure" then
              auto_connect_roots[key] = nil
              return
            end

            local ok, action = pcall(require, "conjure.client.clojure.nrepl.action")

            if not ok or type(action["connect-port-file"]) ~= "function" then
              auto_connect_roots[key] = nil
              return
            end

            action["connect-port-file"]({
              ["silent?"] = true,
            })
          end, 50)
        end,
      })
    end,
  },
}
