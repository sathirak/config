-- git-blame: virtual text blame
local gh = require('util').gh

vim.pack.add { gh 'f-person/git-blame.nvim' }

require('gitblame').setup {
  enabled = true,
  message_template = ' <author> • <date> • <sha>',
  date_format = '%r',
  virtual_text_column = 1,
}
