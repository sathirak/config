-- telescope: fuzzy finder (files, grep, LSP symbols)
local gh = require('util').gh
local keymaps = require 'config.keymaps'

local specs = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
  gh 'nvim-tree/nvim-web-devicons',
}
if vim.fn.executable 'make' == 1 then
  table.insert(specs, gh 'nvim-telescope/telescope-fzf-native.nvim')
end

vim.pack.add(specs)

require('telescope').setup {
  defaults = {
    layout_strategy = 'vertical',
    layout_config = {
      height = 0.85,
      width = 0.80,
    },
    preview = {
      hide_on_startup = true,
    },
    mappings = keymaps.telescope_mappings(),
  },
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
