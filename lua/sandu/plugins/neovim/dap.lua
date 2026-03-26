return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>r", group = "run" },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    cond = function()
      return #vim.api.nvim_list_uis() > 0
    end,
    dependencies = {
      "jay-babu/mason-nvim-dap.nvim",
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
    },
    keys = {
      {
        "<leader>rc",
        function()
          require("dap").continue()
        end,
        desc = "Debug continue",
      },
      {
        "<leader>rl",
        function()
          require("dap").run_last()
        end,
        desc = "Debug run last",
      },
      {
        "<leader>rb",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug toggle breakpoint",
      },
      {
        "<leader>rB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Debug conditional breakpoint",
      },
      {
        "<leader>ro",
        function()
          require("dap").step_over()
        end,
        desc = "Debug step over",
      },
      {
        "<leader>ri",
        function()
          require("dap").step_into()
        end,
        desc = "Debug step into",
      },
      {
        "<leader>rO",
        function()
          require("dap").step_out()
        end,
        desc = "Debug step out",
      },
      {
        "<leader>rt",
        function()
          require("dap").terminate()
        end,
        desc = "Debug terminate",
      },
      {
        "<leader>ru",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug toggle UI",
      },
      {
        "<leader>re",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "v" },
        desc = "Debug evaluate",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual" })

      local js_filetypes = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
      }

      local js_configurations = {
        {
          name = "Launch current file",
          type = "pwa-node",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          console = "integratedTerminal",
        },
        {
          name = "Attach to process",
          type = "pwa-node",
          request = "attach",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
      }

      for _, filetype in ipairs(js_filetypes) do
        dap.configurations[filetype] = js_configurations
      end

      dap.configurations.python = {
        {
          name = "Launch current file",
          type = "python",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          pythonPath = function()
            return vim.fn.exepath("python3")
          end,
        },
      }

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
