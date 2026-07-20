-- telescope: fuzzy finder
local gh = require('util').gh

local specs = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}
if vim.fn.executable 'make' == 1 then
  table.insert(specs, gh 'nvim-telescope/telescope-fzf-native.nvim')
end

vim.pack.add(specs)

require('telescope').setup {
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'

vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search help' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Search keymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'Search telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = 'Search word' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Search grep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search diagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Search resume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = 'Search recent files' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = 'Search commands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Search buffers' })
vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Search in buffer' })
vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = 'Search in open files' })
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true }
end, { desc = 'Search neovim config' })
