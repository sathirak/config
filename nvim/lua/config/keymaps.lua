-- keymaps: global bindings
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic quickfix' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper' })
