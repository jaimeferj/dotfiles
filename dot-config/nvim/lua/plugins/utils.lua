return {
  {
    'ellisonleao/dotenv.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
  },

  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    config = function()
      vim.g.mkdp_auto_close = 0
    end,
    keys = {
      {
        '<leader>nn',
        function()
          local row = vim.api.nvim_win_get_cursor(0)[1] -- fila (1-indexada)
          local line = vim.api.nvim_get_current_line()

          -- 2. Extrae las dos letras mayúsculas según el patrón X[...] --> Y[...]
          local first = line:match '^%s*([A-Z])%[' -- X (por si quieres usarla)
          local second = line:match '%-%-%>%s*([A-Z])%[' -- Y

          if not second then
            vim.notify('Formato no reconocido: se esperaba “X[...] --> Y[...]”', vim.log.levels.WARN)
            return
          end

          -- 3. Calcula la siguiente letra (cíclica Z→A)
          local next_code = ((second:byte() - string.byte 'A' + 1) % 26) + string.byte 'A'
          local next_char = string.char(next_code) -- Z

          -- 4. Construye la línea y la inserta debajo (entre row y row)
          local new_line = string.format('%s --> %s[]', second, next_char)
          vim.api.nvim_buf_set_lines(0, row, row, false, { new_line })
        end,
        mode = 'n',
        desc = 'Insert next node in diagram',
      },
    },
  },

  {
    'mistricky/codesnap.nvim',
    build = 'make',
    keys = {
      { '<leader>cc', '<cmd>CodeSnap<cr>', mode = 'x', desc = 'Save selected code snapshot into clipboard' },
      { '<leader>cs', '<cmd>CodeSnapSave<cr>', mode = 'x', desc = 'Save selected code snapshot in ~/Pictures' },
    },
    opts = {
      has_breadcrumbs = true,
    },
  },

  -- Better Nvim user
  {
    'tris203/precognition.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'Weyaaron/nvim-training',
    event = 'VeryLazy',
    pin = true,
  },
}
