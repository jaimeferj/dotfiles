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
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
      'mfussenegger/nvim-dap-python',
      {
        'jbyuki/one-small-step-for-vimkind',
        keys = {
          {
            '<leader>bsl',
            function()
              require('osv').launch { port = 8086 }
            end,
            desc = 'Launch Lua adapter',
          },
        },
      },
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

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Install golang specific config
      require('dap-go').setup {
        delve = {
          detached = vim.fn.has 'win32' == 0,
        },
      }

      -- Lua Configuration
      dap.adapters.nlua = function(callback, config)
        callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
      end

      dap.configurations['lua'] = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
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

      local dap = require 'dap'

      local original_python_adapter = dap.adapters.python
      dap.adapters.python = function(callback, config)
        -- Your custom enrichment of the config
        local final_config = vim.deepcopy(config)

        -- Placeholder expansion for launch directives
        local placeholders = {
          ['${file}'] = function(_)
            return vim.fn.expand '%:p'
          end,
          ['${fileBasename}'] = function(_)
            return vim.fn.expand '%:t'
          end,
          ['${fileBasenameNoExtension}'] = function(_)
            return vim.fn.fnamemodify(vim.fn.expand '%:t', ':r')
          end,
          ['${fileDirname}'] = function(_)
            return vim.fn.expand '%:p:h'
          end,
          ['${fileExtname}'] = function(_)
            return vim.fn.expand '%:e'
          end,
          ['${relativeFile}'] = function(_)
            return vim.fn.expand '%:.'
          end,
          ['${relativeFileDirname}'] = function(_)
            return vim.fn.fnamemodify(vim.fn.expand '%:.:h', ':r')
          end,
          ['${workspaceFolder}'] = function(_)
            return vim.fn.getcwd()
          end,
          ['${workspaceFolderBasename}'] = function(_)
            return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
          end,
          ['${env:([%w_]+)}'] = function(match)
            return os.getenv(match) or ''
          end,
        }

        if final_config.envFile then
          local filePath = final_config.envFile
          for key, fn in pairs(placeholders) do
            filePath = filePath:gsub(key, fn)
          end

          for line in io.lines(filePath) do
            local words = {}
            for word in string.gmatch(line, '[^=]+') do
              table.insert(words, word)
            end
            if not final_config.env then
              final_config.env = {}
            end
            final_config.env[words[1]] = words[2]
          end
        end

        -- Call the original adapter function with the enriched config
        return original_python_adapter(callback, final_config)
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
        type = 'debugpy',
        request = 'attach',
        name = 'Remote Python: Attach manual',
        port = 5678,
        host = '127.0.0.1',
        mode = 'remote',
        localRoot = vim.fn.getcwd(),
        remoteRoot = vim.fn.getcwd(),
        cwd = vim.fn.getcwd(),
      })
      table.insert(require('dap').configurations.python, {
        type = 'debugpy',
        request = 'attach',
        name = 'Remote Python: Docker Attach manual',
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
