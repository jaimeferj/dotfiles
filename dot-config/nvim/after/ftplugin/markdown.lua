vim.b.sleuth_automatic = 0 -- evita que Sleuth toque el buffer

vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

vim.api.nvim_create_user_command('Pandoc', function(args)
  vim.cmd('!pandoc -i ' .. vim.fn.fnameescape(vim.fn.expand '%') .. ' -o ' .. vim.fn.fnameescape(vim.fn.expand '%:r') .. '.' .. args.args)
end, {
  nargs = 1,
})

vim.api.nvim_create_user_command('PandocD', function()
  vim.cmd(
    '!pandoc -F mermaid-filter -i '
      .. vim.fn.fnameescape(vim.fn.expand '%')
      .. ' -o '
      .. vim.fn.expand '"$HOME/Documents/'
      .. vim.fn.fnameescape(vim.fn.expand '%:r')
      .. '.pdf"'
  )
end, {
  nargs = 0,
})
