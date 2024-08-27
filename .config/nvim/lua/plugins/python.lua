local map = vim.keymap.set

return {

  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      map("n", "<leader>bb", "<cmd> DapToggleBreakpoint <CR>")
      map("n", "<leader>bc", "<cmd> lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) <CR>")
      map(
        "n",
        "<leader>bl",
        "<cmd> lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) <CR>"
      )
      map("n", "<leader>br", "<cmd> lua require'dap'.clear_breakpoints() <CR>")
      map("n", "<leader>ba", "<cmd> Telescope dap list_breakpoints <CR>")
      map("n", "<leader>dc", "<cmd> lua require'dap'.continue() <CR>")
      map("n", "<leader>dj", "<cmd> lua require'dap'.step_over() <CR>")
      map("n", "<leader>dk", "<cmd> lua require'dap'.step_into() <CR>")
      map("n", "<leader>do", "<cmd> lua require'dap'.step_out() <CR>")
      map("n", "<leader>dd", function()
        require("dap").disconnect()
        require("dapui").close()
      end)
      map("n", "<leader>dt", function()
        require("dap").terminate()
        require("dapui").close()
      end)
      map("n", "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<CR>")
      map("n", "<leader>dl", "<cmd>lua require'dap'.run_last()<CR>")
      map("n", "<leader>di", function()
        require("dap.ui.widgets").hover()
      end)
      map("n", "<leader>d?", function()
        local widgets = require "dap.ui.widgets"
        widgets.centered_float(widgets.scopes)
      end)
      map("n", "<leader>df", "<cmd> Telescope dap frames <CR>")
      map("n", "<leader>dh", "<cmd> Telescope dap commands <CR>")
      map("n", "<leader>de", function()
        require("telescope.builtin").diagnostics { default_text = ":E:" }
      end)
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function(_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
    end,
  },

  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "mfussenegger/nvim-dap-python", --optional
      {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    lazy = false,
    branch = "regexp", -- This is the regexp branch, use this for the new version
    config = function()
      require("venv-selector").setup()
    end,
    keys = {
      { ",v", "<cmd>VenvSelect<cr>" },
    },
  },
}
