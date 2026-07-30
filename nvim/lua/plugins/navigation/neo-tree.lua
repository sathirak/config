-- neo-tree: file explorer (snacks-like nav)
local gh = require('util').gh

vim.pack.add {
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

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
    mappings = {
      ['\\'] = 'close_window',
      ['<cr>'] = 'open',
      ['l'] = 'open',
      ['h'] = function(state)
        local node = state.tree:get_node()
        if node.type == 'directory' and (node:is_expanded() or node.empty_expanded) then
          state.commands.toggle_node(state)
        else
          require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
        end
      end,
      ['Z'] = 'close_all_nodes',
      ['z'] = 'none',
    },
  },
  filesystem = {
    scan_mode = 'deep',
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = false,
    },
    window = {
      mappings = {
        ['<bs>'] = 'navigate_up',
        ['.'] = 'set_root',
        ['H'] = 'toggle_hidden',
        ['I'] = function(state)
          state.filtered_items.hide_gitignored = not state.filtered_items.hide_gitignored
          require('neo-tree.sources.manager').refresh(state.name)
        end,
      },
    },
  },
}
