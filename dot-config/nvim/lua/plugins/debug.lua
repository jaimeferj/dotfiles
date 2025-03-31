return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Creates a beautiful debugger UI
      {
        'rcarriga/nvim-dap-ui',
        opts = {
          icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
          controls = {
            icons = {
              pause = '⏸',
              play = '▶',
              step_into = '⏎',
              step_over = '⏭',
              step_out = '⏮',
              step_back = 'b',
              run_last = '▶▶',
              terminate = '⏹',
              disconnect = '⏏',
            },
          },
          layouts = {
            {
              elements = {
                { id = 'stacks', size = 0.3 },
                { id = 'breakpoints', size = 0.1 },
                { id = 'scopes', size = 0.3 },
                { id = 'watches', size = 0.2 },
              },
              position = 'right',
              size = 40,
            },
            {
              elements = {
                { id = 'repl', size = 1.0 },
              },
              position = 'bottom',
              size = 5,
            },
          },
        },
      },

      -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
    },
    keys = function(_, keys)
      local dap = require 'dap'
      local dapui = require 'dapui'
      return {
        -- Basic debugging keymaps, feel free to change to your liking!
        {
          '<F5>',
          function()
            if vim.fn.filereadable '.vscode/launch.json' then
              require('dap.ext.vscode').load_launchjs()
            end
            require('dap').continue()
          end,
          desc = 'Debug: Start/Continue',
        },
        { '<F1>', dap.step_into, desc = 'Debug: Step Into' },
        { '<F2>', dap.step_over, desc = 'Debug: Step Over' },
        { '<F3>', dap.step_out, desc = 'Debug: Step Out' },
        { '<leader>bb', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
        {
          '<leader>bc',
          function()
            dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
          end,
          desc = 'Debug: Set Breakpoint',
        },
        {
          '<leader>bl',
          function()
            dap.set_breakpoint(nil, nil, vim.fn.input 'Breakpoint log message: ')
          end,
          desc = 'Debug: Breakpoing Log point',
        },
        { '<leader>br', dap.toggle_breakpoint, desc = 'Debug: Breakpoint Clear' },
        { '<leader>ba', dap.toggle_breakpoint, desc = 'Debug: Breakpoint List All' },
        -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
        { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
        {
          '<leader>dd',
          function()
            require('dap').disconnect()
            require('dapui').close()
          end,
          desc = 'Debug: Disconnect',
        },
        {
          '<leader>dt',
          function()
            require('dap').terminate()
            require('dapui').close()
          end,
          desc = 'Debug: Terminate',
        },
        { '<leader>dr', dap.repl.toggle, desc = 'Debug: Toggle REPL' },
        { '<leader>dl', dap.run_last, desc = 'Debug: Run Last' },
        {
          '<leader>di',
          function()
            require('dap.ui.widgets').hover()
          end,
          desc = 'Debug: Hover',
        },
        {
          '<leader>d?',
          function()
            local widgets = require 'dap.ui.widgets'
            widgets.centered_float(widgets.scopes)
          end,
          desc = 'Debug: Scopes',
        },
        {
          '<leader>di',
          function()
            require('dap-ui').eval()
          end,
          desc = 'Debug: Hover Selection (Eval)',
          mode = 'v',
        },
        { '<leader>df', '<cmd> Telescope dap frames <CR>', desc = 'Debug: Frames' },
        { '<leader>dh', '<cmd> Telescope dap commands <CR>', desc = 'Debug: Commands' },
        {
          '<leader>de',
          function()
            require('telescope.builtin').diagnostics { default_text = ':E:' }
          end,
          desc = 'Debug: Diagnostics',
        },
        unpack(keys),
      }
    end,
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    opts = {
      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
      },
      automatic_installation = true,
    },
  },
}
