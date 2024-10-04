return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',

      -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
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
        },
        {
          '<leader>dt',
          function()
            require('dap').terminate()
            require('dapui').close()
          end,
        },
        { '<leader>dr', dap.repl.toggle },
        { '<leader>dl', dap.run_last },
        {
          '<leader>di',
          function()
            require('dap.ui.widgets').hover()
          end,
        },
        {
          '<leader>d?',
          function()
            local widgets = require 'dap.ui.widgets'
            widgets.centered_float(widgets.scopes)
          end,
        },
        { '<leader>df', '<cmd> Telescope dap frames <CR>' },
        { '<leader>dh', '<cmd> Telescope dap commands <CR>' },
        {
          '<leader>de',
          function()
            require('telescope.builtin').diagnostics { default_text = ':E:' }
          end,
        },
        unpack(keys),
      }
    end,
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          'python',
          'debugpy',
          'delve',
        },
      }

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
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
      }

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Install golang specific config
      require('dap-go').setup {
        delve = {
          detached = vim.fn.has 'win32' == 0,
        },
      }
    end,
  },

  {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
    },
    config = function(_, _)
      local path = '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
      require('dap-python').setup(path)

      local get_python_path = function()
        local venv_path = os.getenv 'VIRTUAL_ENV'
        if venv_path then
          return venv_path .. '/bin/python'
        end

        return nil
      end

      table.insert(require('dap').configurations.python, {
        justMyCode = false,
        type = 'python',
        request = 'launch',
        name = 'Python Launch File: JustMyCode=false',
        program = '${file}',
        cwd = vim.fn.getcwd(),
        pythonPath = get_python_path(),
      })
      table.insert(require('dap').configurations.python, {
        type = 'python',
        request = 'attach',
        name = 'Remote Python: Attach manual',
        port = 5678,
        host = '127.0.0.1',
        mode = 'remote',
        cwd = vim.fn.getcwd(),
        pathMappings = {
          {
            localRoot = function()
              return vim.fn.input('Local code folder > ', vim.fn.getcwd(), 'file')
            end,
            remoteRoot = function()
              return vim.fn.input('Container code folder > ', '/', 'file')
            end,
          },
        },
      })
    end,
  },
}
