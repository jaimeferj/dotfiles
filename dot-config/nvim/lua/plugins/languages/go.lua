-- -- Debugging
-- require('dap-go').setup {
--   delve = {
--     detached = vim.fn.has 'win32' == 0,
--   },
-- }
--
return {
  -- Formatting
  {
    'stevearc/conform.nvim',
    opts = { formatters_by_ft = {
      go = { 'gofmt', 'goimports', 'golines' },
    } },
  },

  -- Debugging
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'leoluz/nvim-dap-go',
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

  lsp = {
    gopls = {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      },
      filetypes = { 'go' },
    },
  },
}
