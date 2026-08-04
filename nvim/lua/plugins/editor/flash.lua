-- flash: jump labels / treesitter select
local gh = require('util').gh

vim.pack.add { gh 'folke/flash.nvim' }

require('flash').setup {}
