-- gitsigns: gutter signs
local gh = require('util').gh

vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
require('gitsigns').setup {
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '' },
    topdelete = { text = '' },
    changedelete = { text = '▎' },
    untracked = { text = '▎' },
  },
  signs_staged = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '' },
    topdelete = { text = '' },
    changedelete = { text = '▎' },
  },
  on_attach = function(bufnr)
    if vim.bo[bufnr].filetype == 'neo-tree' then return false end
  end,
}
