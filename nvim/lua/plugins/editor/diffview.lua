-- diffview: git diff UI
local gh = require('util').gh

vim.pack.add { gh 'sindrets/diffview.nvim' }
require('diffview').setup {}
