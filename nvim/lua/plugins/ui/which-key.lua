-- which-key: :WhichKey only (no auto triggers / keymaps)
local gh = require('util').gh

vim.pack.add { gh 'folke/which-key.nvim' }

require('which-key').setup {
  triggers = {},
}
