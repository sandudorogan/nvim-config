return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        enable = true,
        lookahead = true,
      },
      move = {
        enable = true,
        set_jumps = true,
      },
      swap = {
        enable = true,
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local repeatable_move = require("nvim-treesitter-textobjects.repeatable_move")
    local swap = require("nvim-treesitter-textobjects.swap")

    local function set_mode_keymaps(modes, lhs, callback, opts)
      opts = opts or {}
      opts.silent = true
      vim.keymap.set(modes, lhs, callback, opts)
    end

    local function map_select(bufnr, lhs, query, desc, query_group)
      query_group = query_group or "textobjects"
      for _, mode in ipairs({ "o", "x" }) do
        set_mode_keymaps(mode, lhs, function()
          select.select_textobject(query, query_group)
        end, { buffer = bufnr, desc = desc })
      end
    end

    local function map_move(bufnr, lhs, fn, query, desc, query_group)
      query_group = query_group or "textobjects"
      set_mode_keymaps({ "n", "x", "o" }, lhs, function()
        fn(query, query_group)
      end, { buffer = bufnr, desc = desc })
    end

    local function map_swap(bufnr, lhs, fn, query, desc, query_group)
      query_group = query_group or "textobjects"
      set_mode_keymaps("n", lhs, function()
        fn(query, query_group)
      end, { buffer = bufnr, desc = desc })
    end

    local function attach(bufnr)
      if vim.b[bufnr].sandu_treesitter_textobjects_attached then
        return
      end

      if vim.bo[bufnr].buftype ~= "" then
        return
      end

      if not vim.treesitter.get_parser(bufnr, nil, { error = false }) then
        return
      end

      map_select(bufnr, "a=", "@assignment.outer", "Select outer part of an assignment")
      map_select(bufnr, "i=", "@assignment.inner", "Select inner part of an assignment")
      map_select(bufnr, "l=", "@assignment.lhs", "Select left hand side of an assignment")
      map_select(bufnr, "r=", "@assignment.rhs", "Select right hand side of an assignment")

      -- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
      map_select(bufnr, "a:", "@property.outer", "Select outer part of an object property")
      map_select(bufnr, "i:", "@property.inner", "Select inner part of an object property")
      map_select(bufnr, "l:", "@property.lhs", "Select left part of an object property")
      map_select(bufnr, "r:", "@property.rhs", "Select right part of an object property")

      map_select(bufnr, "aa", "@parameter.outer", "Select outer part of a parameter/argument")
      map_select(bufnr, "ia", "@parameter.inner", "Select inner part of a parameter/argument")

      map_select(bufnr, "ai", "@conditional.outer", "Select outer part of a conditional")
      map_select(bufnr, "ii", "@conditional.inner", "Select inner part of a conditional")

      map_select(bufnr, "al", "@loop.outer", "Select outer part of a loop")
      map_select(bufnr, "il", "@loop.inner", "Select inner part of a loop")

      map_select(bufnr, "af", "@call.outer", "Select outer part of a function call")
      map_select(bufnr, "if", "@call.inner", "Select inner part of a function call")

      map_select(bufnr, "am", "@function.outer", "Select outer part of a method/function definition")
      map_select(bufnr, "im", "@function.inner", "Select inner part of a method/function definition")

      map_select(bufnr, "ac", "@class.outer", "Select outer part of a class")
      map_select(bufnr, "ic", "@class.inner", "Select inner part of a class")

      map_swap(bufnr, "<leader>na", swap.swap_next, "@parameter.inner", "Swap parameter/argument with next")
      map_swap(bufnr, "<leader>n:", swap.swap_next, "@property.outer", "Swap object property with next")
      map_swap(bufnr, "<leader>nm", swap.swap_next, "@function.outer", "Swap function with next")

      map_swap(bufnr, "<leader>pa", swap.swap_previous, "@parameter.inner", "Swap parameter/argument with previous")
      map_swap(bufnr, "<leader>p:", swap.swap_previous, "@property.outer", "Swap object property with previous")
      map_swap(bufnr, "<leader>pm", swap.swap_previous, "@function.outer", "Swap function with previous")

      map_move(bufnr, "]f", move.goto_next_start, "@call.outer", "Next function call start")
      map_move(bufnr, "]m", move.goto_next_start, "@function.outer", "Next method/function def start")
      map_move(bufnr, "]c", move.goto_next_start, "@class.outer", "Next class start")
      map_move(bufnr, "]i", move.goto_next_start, "@conditional.outer", "Next conditional start")
      map_move(bufnr, "]l", move.goto_next_start, "@loop.outer", "Next loop start")
      map_move(bufnr, "]s", move.goto_next_start, "@scope", "Next scope", "locals")
      map_move(bufnr, "]z", move.goto_next_start, "@fold", "Next fold", "folds")

      map_move(bufnr, "]F", move.goto_next_end, "@call.outer", "Next function call end")
      map_move(bufnr, "]M", move.goto_next_end, "@function.outer", "Next method/function def end")
      map_move(bufnr, "]C", move.goto_next_end, "@class.outer", "Next class end")
      map_move(bufnr, "]I", move.goto_next_end, "@conditional.outer", "Next conditional end")
      map_move(bufnr, "]L", move.goto_next_end, "@loop.outer", "Next loop end")

      map_move(bufnr, "[f", move.goto_previous_start, "@call.outer", "Prev function call start")
      map_move(bufnr, "[m", move.goto_previous_start, "@function.outer", "Prev method/function def start")
      map_move(bufnr, "[c", move.goto_previous_start, "@class.outer", "Prev class start")
      map_move(bufnr, "[i", move.goto_previous_start, "@conditional.outer", "Prev conditional start")
      map_move(bufnr, "[l", move.goto_previous_start, "@loop.outer", "Prev loop start")

      map_move(bufnr, "[F", move.goto_previous_end, "@call.outer", "Prev function call end")
      map_move(bufnr, "[M", move.goto_previous_end, "@function.outer", "Prev method/function def end")
      map_move(bufnr, "[C", move.goto_previous_end, "@class.outer", "Prev class end")
      map_move(bufnr, "[I", move.goto_previous_end, "@conditional.outer", "Prev conditional end")
      map_move(bufnr, "[L", move.goto_previous_end, "@loop.outer", "Prev loop end")

      -- vim way: ; goes to the direction you were moving.
      set_mode_keymaps({ "n", "x", "o" }, ";", repeatable_move.repeat_last_move, { buffer = bufnr })
      set_mode_keymaps({ "n", "x", "o" }, ",", repeatable_move.repeat_last_move_opposite, { buffer = bufnr })

      -- Make builtin f, F, t, T repeatable with ; and , in Treesitter-backed buffers only.
      set_mode_keymaps({ "n", "x", "o" }, "f", repeatable_move.builtin_f_expr, { buffer = bufnr, expr = true })
      set_mode_keymaps({ "n", "x", "o" }, "F", repeatable_move.builtin_F_expr, { buffer = bufnr, expr = true })
      set_mode_keymaps({ "n", "x", "o" }, "t", repeatable_move.builtin_t_expr, { buffer = bufnr, expr = true })
      set_mode_keymaps({ "n", "x", "o" }, "T", repeatable_move.builtin_T_expr, { buffer = bufnr, expr = true })

      vim.b[bufnr].sandu_treesitter_textobjects_attached = true
    end

    local group = vim.api.nvim_create_augroup("sandu-treesitter-textobjects", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(ev)
        attach(ev.buf)
      end,
    })

    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        attach(bufnr)
      end
    end
  end,
}
