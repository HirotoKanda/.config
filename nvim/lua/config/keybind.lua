-- Keybind
vim.opt.clipboard = "unnamedplus"
vim.keymap.set('n', 'q:', '<nop>', { desc = 'Disable cmdwin' })
vim.keymap.set('n', '<C-n>', ':Neotree filesystem toggle left<CR>')
vim.keymap.set('i', '<C-z>', '<Esc>ui')






