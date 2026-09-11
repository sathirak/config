-- markdown: GitHub-like in-buffer README / markdown preview
local gh = require('util').gh

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  file_types = { 'markdown' },
  render_modes = { 'n', 'c', 't' },
  heading = {
    border = true,
    width = 'block',
  },
  code = {
    width = 'block',
    border = 'thin',
  },
  pipe_table = {
    style = 'normal',
  },
  sign = { enabled = false },
}

vim.keymap.set('n', '<leader>um', '<cmd>RenderMarkdown toggle<cr>', { desc = 'Toggle Markdown Preview' })
