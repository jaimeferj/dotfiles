-- Debugging
local dap = require 'dap'
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

return {
  -- Formatting
  {
    'stevearc/conform.nvim',
    opts = { formatters_by_ft = {
      lua = { 'stylua' },
    } },
  },

  -- Debugging
  {
    'mfussenegger/nvim-dap',
    dependencies = {
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
  },
  lsp = {
    lua_ls = {
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
          -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
          -- diagnostics = { disable = { 'missing-fields' } },
        },
      },
    },
  },
}
