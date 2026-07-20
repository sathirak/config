-- mini: surround
local gh = require('util').gh

vim.pack.add { gh 'nvim-mini/mini.nvim' }
require('mini.surround').setup()
