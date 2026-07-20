-- todo-comments: highlight TODO/FIXME/etc
local gh = require('util').gh

vim.pack.add { gh 'folke/todo-comments.nvim' }
require('todo-comments').setup { signs = false }
