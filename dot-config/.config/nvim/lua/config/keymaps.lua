-- [[ Basic Keymaps ]]
--
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
local set_keymap = vim.keymap.set
set_keymap('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
set_keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set_keymap('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
set_keymap('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
set_keymap('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
set_keymap('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
set_keymap('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Execute current lua line
set_keymap('v', '<leader>xx', ':lua<CR>')
set_keymap('n', '<leader>xx', ':.lua<CR>')

-- Quickfix List

set_keymap('n', '<leader>j', '<cmd>cnext<cr>', { desc = 'Go to next quickfix' })
set_keymap('n', '<leader>k', '<cmd>cprev<cr>', { desc = 'Go to previous quickfix' })
set_keymap('v', '<leader>p', '"_dP', { desc = 'Delete to register _' })
set_keymap('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostic' })
set_keymap('n', 'gK', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
set_keymap('i', '<c-k>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
