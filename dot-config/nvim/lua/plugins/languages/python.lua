--Linting
local linters = require('lint').linters_by_ft or {}
require('lint').linters_by_ft = vim.tbl_extend('force', linters, { python = { 'ruff' } })

return {

  -- Formatting
  {
    'stevearc/conform.nvim',
    opts = { formatters_by_ft = {
      python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
    } },
  },

  -- Debugging
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'mfussenegger/nvim-dap-python',
    },
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

  -- Optional LSP configuration for Python
  lsp = {
    pyright = {
      settings = {
        python = {
          analysis = {
            typeCheckingMode = 'basic',
            -- add other settings as needed
          },
        },
      },
      filetypes = { 'python' },
    },
    ruff = {
      capabilities = { hoverProvider = false },
      filetypes = { 'python' },
    },
  },

  {
    'jay-babu/mason-nvim-dap.nvim',
    opts = {
      ensure_installed = {
        'python',
        'debugpy',
      },
    },
  },

  -- Other plugins

  {
    'Vigemus/iron.nvim',
    ft = 'python',
    event = 'VeryLazy',
    config = function()
      local iron = require 'iron.core'

      iron.setup {
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            sh = {
              command = { 'zsh' },
            },
            python = {
              command = { 'ipython', '--no-autoindent' }, -- { "ipython", "--no-autoindent" } or { "python" }
              format = require('iron.fts.common').bracketed_paste_python,
            },
          },
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = 'horizontal botright 15 split',
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          send_motion = '<space>xc',
          visual_send = '<space>xv',
          send_file = '<space>xf',
          send_line = '<space>xl',
          send_paragraph = '<space>xp',
          send_until_cursor = '<space>xu',
          cr = '<space>x<cr>',
          interrupt = '<space>x<space>',
          exit = '<space>xq',
          -- clear = '<space>cl',
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }

      -- iron also has a list of commands, see :h iron-commands for all available commands
      vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
      vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
      vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
      vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
      vim.keymap.set('n', '<space>xx', function()
        vim.cmd.normal ' xciN'
        vim.cmd.normal 'vaN'
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
      end, { noremap = true, silent = true })
    end,
  },
}
