return {

  {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python', --optional
      'nvim-telescope/telescope.nvim',
    },
    lazy = false,
    branch = 'regexp', -- This is the regexp branch, use this for the new version
    config = function()
      require('venv-selector').setup()
    end,
    keys = {
      { ',v', '<cmd>VenvSelect<cr>' },
    },
  },

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
              -- Can be a table or a function that
              -- returns a table (see below)
              command = { 'zsh' },
            },
            python = {
              command = { 'python' }, -- or { "ipython", "--no-autoindent" }
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
          --          send_motion = '<space>sc',
          --          visual_send = '<space>sc',
          --          send_file = '<space>sf',
          --          send_line = '<space>sl',
          --          send_paragraph = '<space>sp',
          --          send_until_cursor = '<space>su',
          --          cr = '<space>s<cr>',
          --          interrupt = '<space>s<space>',
          --          exit = '<space>sq',
          --          clear = '<space>cl',
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
      vim.keymap.set('n', '<space>x', function()
        vim.cmd.normal ' sciN'
        vim.cmd.normal 'vaN'
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
      end, { noremap = true, silent = true })
    end,
  },
}
