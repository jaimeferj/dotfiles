return {

  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/neotest-python',
    },
    keys = function(_, keys)
      local nt = require 'neotest'
      return {
        {
          '<leader>tf',
          function()
            nt.run.run(vim.fn.expand '%')
          end,
          desc = 'Test: [F]ile',
        },
        {
          '<leader>tn',
          function()
            nt.run.run()
          end,
          desc = 'Test: [N]ext',
        },
        {
          '<leader>tdn',
          function()
            nt.run.run { strategy = 'dap' }
          end,
          desc = 'Test: [D]ebug [N]ext',
        },
        {
          '<leader>tsn',
          function()
            nt.run.stop()
          end,
          desc = 'Test: [S]top [N]earest',
        },
        {
          '<leader>tst',
          function()
            nt.summary.toggle()
          end,
          desc = 'Test: [S]ummary [T]oggle',
        },
        {
          '<leader>tos',
          function()
            nt.output.open()
          end,
          desc = 'Test: [O]utput [S]how',
        },
        {
          '<leader>toS',
          function()
            nt.output.open { enter = true }
          end,
          desc = 'Test: [O]utput [S]how Enter',
        },
        {
          '<leader>tol',
          function()
            nt.output.open { last_run = true }
          end,
          desc = 'Test: [O]utput [L]ast',
        },
        {
          '<leader>ton',
          function()
            nt.output.open { position_id = '' }
          end,
          desc = 'Test: [O]utput [N]earest',
        },
      }
    end,
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-python' {
            dap = { justMyCode = false },
            args = { '--log-level', 'DEBUG' },
            runner = 'pytest',
          },
        },
      }
    end,
  },
}
