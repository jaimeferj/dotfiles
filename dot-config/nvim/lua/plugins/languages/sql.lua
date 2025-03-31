return {
  'neovim/nvim-lspconfig',
  lsp = {
    sqlls = {
      cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
      filetypes = { 'sql' },
    },
  },
}
