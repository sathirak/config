-- neo-tree: file explorer (snacks-like nav)
local gh = require('util').gh
local keymaps = require 'config.keymaps'

vim.pack.add {
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
}

require('neo-tree').setup {
  enable_git_status = false,
  default_component_configs = {
    icon = {
      folder_closed = '',
      folder_open = '',
      folder_empty = '',
      folder_empty_open = '',
      default = '',
      -- nvim-web-devicons would otherwise fill file icons
      provider = function(icon, node)
        if node.type == 'file' then
          icon.text = ''
          icon.highlight = nil
        end
        return icon
      end,
    },
    name = { use_git_status_colors = false },
  },
  renderers = {
    directory = {
      { 'indent' },
      { 'icon' },
      { 'current_filter' },
      { 'name' },
    },
    file = {
      { 'indent' },
      { 'name' },
    },
  },
  window = {
    mappings = keymaps.neo_tree_window_mappings(),
  },
  filesystem = {
    scan_mode = 'deep',
    hide_root_node = true,
    -- keep the tree on the buffer you are editing, and pick up on-disk changes
    follow_current_file = {
      enabled = true,
      leave_dirs_open = true,
    },
    use_libuv_file_watcher = true,
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = false,
    },
    window = {
      mappings = keymaps.neo_tree_filesystem_window_mappings(),
    },
  },
}
