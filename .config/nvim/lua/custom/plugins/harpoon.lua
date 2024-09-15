return {

  {
    'ThePrimeagen/harpoon',
    event = { 'VeryLazy' },
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()
      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = 'Harpoon Add current file' })
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Harpoon Open quick menu' })
      vim.keymap.set('n', '<A-h>', function()
        harpoon:list():select(1)
      end, { desc = 'Harpoon Go to 1' })
      vim.keymap.set('n', '<A-j>', function()
        harpoon:list():select(2)
      end, { desc = 'Harpoon Go to 2' })
      vim.keymap.set('n', '<A-k>', function()
        harpoon:list():select(3)
      end, { desc = 'Harpoon Go to 3' })
      vim.keymap.set('n', '<A-l>', function()
        harpoon:list():select(4)
      end, { desc = 'Harpoon Go to 4' })
      -- Toggle previous & next buffers stored within Harpoon list
      -- vim.keymap.set("n", "<C-p>", function()
      --   harpoon:list():prev()
      -- end, { desc = "Harpoon Go to previous" })
      -- vim.keymap.set("n", "<C-n>", function()
      --   harpoon:list():next()
      -- end, { desc = "Harpoon Go to next" })
    end,
  },
}
