-- navbuddy: LSP symbol outline
local gh = require('util').gh

vim.pack.add {
  gh 'SmiteshP/nvim-navbuddy',
  gh 'SmiteshP/nvim-navic',
  gh 'MunifTanjim/nui.nvim',
}

local actions = require 'nvim-navbuddy.actions'

require('nvim-navbuddy').setup {
  lsp = { auto_attach = true },
  window = {
    border = 'rounded',
    sections = {
      left = { size = '20%' },
      mid = { size = '40%' },
      right = { preview = 'leaf' },
    },
  },
  node_markers = {
    enabled = true,
    icons = {
      leaf = '  ',
      leaf_selected = ' ❯ ',
      branch = '  ',
    },
  },
  mappings = {
    ['<Left>'] = actions.parent(),
    ['<Right>'] = actions.children(),
    ['h'] = actions.parent(),
    ['l'] = actions.children(),
  },
  use_default_mappings = true,
}

vim.keymap.set('n', '<leader>n', '<cmd>Navbuddy<cr>', { desc = 'Navbuddy' })
