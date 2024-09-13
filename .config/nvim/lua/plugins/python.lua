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
  "nvim-telescope/telescope-dap.nvim",
  {
    "mfussenegger/nvim-dap",
    config = function()
      require('telescope').load_extension('dap')
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
      table.insert(require('dap').configurations.python, {
        type = 'python',
        request = 'attach',
        name = 'Remote Python: Attach',
        port = 5678,
        host = "127.0.0.1",
        mode = "remote",
        cwd = vim.fn.getcwd(),
        pathMappings = {
          {
            localRoot = function()
              return vim.fn.input("Local code folder > ", vim.fn.getcwd(), "file")
            end,
            remoteRoot = function()
              return vim.fn.input("Container code folder > ", "/", "file")
            end,
          },
        },
      })
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
  {
    "Vigemus/iron.nvim",
    event = "VeryLazy",
    config = function()
      local iron = require("iron.core")

      iron.setup {
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            sh = {
              -- Can be a table or a function that
              -- returns a table (see below)
              command = { "zsh" }
            },
            python = {
              command = { "python" }, -- or { "ipython", "--no-autoindent" }
              format = require("iron.fts.common").bracketed_paste_python
            }
          },
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = "horizontal botright 15 split"
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          send_motion = "<space>sc",
          visual_send = "<space>sc",
          send_file = "<space>sf",
          send_line = "<space>sl",
          send_paragraph = "<space>sp",
          send_until_cursor = "<space>su",
          cr = "<space>s<cr>",
          interrupt = "<space>s<space>",
          exit = "<space>sq",
          clear = "<space>cl",
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }

      -- iron also has a list of commands, see :h iron-commands for all available commands
      vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
      vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
      vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
      vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
      vim.keymap.set('n', '<space>x', function()
        vim.cmd.normal(" sciN")
        vim.cmd.normal("vaN")
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'n', true)
      end, { noremap = true, silent = true })
    end
  },

  {
    "chrisgrieser/nvim-various-textobjs",
    ft = "python",
    event = "UIEnter",
    opts = { useDefaultKeymaps = true },
  },

}
