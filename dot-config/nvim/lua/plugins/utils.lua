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
    build = ':call mkdp#util#install()',
    config = function()
      vim.g.mkdp_auto_close = 0
    end,
  },

  {
    'amitds1997/remote-nvim.nvim',
    version = '*', -- Pin to GitHub releases
    dependencies = {
      'nvim-lua/plenary.nvim', -- For standard functions
      'MunifTanjim/nui.nvim', -- To build the plugin UI
      'nvim-telescope/telescope.nvim', -- For picking b/w different remote methods
    },
    config = true,
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
