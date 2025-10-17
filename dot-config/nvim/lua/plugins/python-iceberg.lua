-- lua/plugins/python-pyiceberg.lua
local util = require 'lspconfig.util'

local function in_pyiceberg()
  local root = util.root_pattern('pyproject.toml', '.git')(vim.fn.getcwd()) or vim.fn.getcwd()
  return root:find 'iceberg%-python' or root:find 'pyiceberg'
end

return {
  {
    'neovim/nvim-lspconfig',
    init = function()
      local function disable_pyright_diagnostics(client)
        -- opcional: baja carga en el servidor
        client.config.settings = vim.tbl_deep_extend('force', client.config.settings or {}, {
          python = { analysis = { typeCheckingMode = 'off', diagnosticMode = 'openFilesOnly' } },
        })
        pcall(client.notify, 'workspace/didChangeConfiguration', { settings = client.config.settings })
        -- anula sólo los diagnósticos de pyright
        client.handlers['textDocument/publishDiagnostics'] = function() end
      end

      -- para clientes nuevos
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('pyiceberg_pyright_no_diags', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= 'pyright' then
            return
          end
          if in_pyiceberg() then
            disable_pyright_diagnostics(client)
          end
        end,
      })
    end,
  },
  {
    'mfussenegger/nvim-lint',
    cond = in_pyiceberg,
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = lint.linters_by_ft or {}
      lint.linters_by_ft.python = { 'mypy' }

      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter' }, {
        group = vim.api.nvim_create_augroup('pyiceberg_mypy_uv', { clear = true }),
        pattern = '*.py',
        callback = function()
          require('lint').try_lint { 'mypy' }
        end,
      })

      -- Atajo manual
      vim.keymap.set('n', '<leader>im', function()
        require('lint').try_lint { 'mypy' }
      end, { desc = 'mypy (uvx) en repo' })
    end,
  },

  -- Black vía Poetry
  {
    'stevearc/conform.nvim',
    cond = in_pyiceberg(),
    opts = {
      format_on_save = { lsp_fallback = true, timeout_ms = 2000 },
      formatters_by_ft = { python = { 'black' } },
    },
    config = function(_, opts)
      local conform = require 'conform'
      conform.setup(opts)
      conform.formatters.black = { command = 'poetry', args = { 'run', 'black', '-' }, stdin = true }
    end,
  },
}
