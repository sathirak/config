-- neo-tree: file explorer (snacks-like nav)
local gh = require('util').gh
local keymaps = require 'config.keymaps'

vim.pack.add {
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
}

require('neo-tree').setup {
  hide_root_node = true,
  -- blank neo-tree windows left by mksession get cleaned on restore
  auto_clean_after_session_restore = true,
  enable_git_status = false,
  enable_diagnostics = true,
  enable_opened_markers = true,
  default_component_configs = {
    icon = {
      folder_closed = '',
      folder_open = '',
      folder_empty = '',
      folder_empty_open = '',
      default = '',
      provider = function(icon, node)
        if node.type == 'file' then
          icon.text = ''
          icon.highlight = nil
        end
        return icon
      end,
    },
    name = {
      use_git_status_colors = false,
      highlight_opened_files = true,
    },
    diagnostics = {
      symbols = {
        error = ' ',
        warn = ' ',
        info = ' ',
        hint = ' ',
      },
      highlights = {
        error = 'DiagnosticError',
        warn = 'DiagnosticWarn',
        info = 'DiagnosticInfo',
        hint = 'DiagnosticHint',
      },
    },
  },
  renderers = {
    directory = {
      { 'indent' },
      { 'icon' },
      { 'current_filter' },
      { 'name' },
      { 'diagnostics', errors_only = true },
    },
    file = {
      { 'indent' },
      { 'name' },
      { 'diagnostics' },
    },
  },
  window = {
    mappings = keymaps.neo_tree_window_mappings(),
    width = 40,
  },
  filesystem = {
    scan_mode = 'deep',
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
