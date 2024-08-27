return {

  {
    "nvim-lua/plenary.nvim",
    event = false,
  },

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require "configs.telescope"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "python",
        "go",
      },
    },
  },

  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig",
    lazy = false,
    opts = {
      ensure_installed = { "lua_ls", "gopls", "ruff", "pyright" },
      automatic_installation = true
    },
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "nvchad.configs.lspconfig"
      require "configs.lspconfig"
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
}
