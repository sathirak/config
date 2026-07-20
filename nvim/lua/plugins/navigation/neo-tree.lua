-- neo-tree: file explorer (snacks-like nav, eternal folder colors, full-width selection)
local gh = require('util').gh

vim.pack.add {
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
}

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

local peach = '#fab387'
local flamingo = '#f2cdcd'
local yellow = '#f9e2af'
local select_ns = vim.api.nvim_create_namespace 'neo-tree-selection'

local function neo_tree_highlights()
  vim.api.nvim_set_hl(0, 'Directory', { fg = peach })
  vim.api.nvim_set_hl(0, 'NeoTreeDirectoryIcon', { fg = peach })
  vim.api.nvim_set_hl(0, 'NeoTreeDirectoryName', { fg = flamingo })
  vim.api.nvim_set_hl(0, 'NeoTreeRootName', { fg = yellow, bold = true })
  vim.api.nvim_set_hl(0, 'NeoTreeExpander', { fg = flamingo })
  vim.api.nvim_set_hl(0, 'NeoTreeCursorLine', { bg = '#ffffff', fg = '#000000', bold = true })
end

local function paint_selection(buf, line, win)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.bo[buf].filetype ~= 'neo-tree' then
    return
  end
  if line < 1 or line > vim.api.nvim_buf_line_count(buf) then
    return
  end

  vim.b[buf].neo_tree_selected_line = line
  vim.api.nvim_buf_clear_namespace(buf, select_ns, 0, -1)

  local text = vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1] or ''
  local opts = {
    line_hl_group = 'NeoTreeCursorLine',
    hl_eol = true,
    priority = 10000,
  }

  if #text > 0 then
    opts.end_col = #text
    opts.hl_group = 'NeoTreeCursorLine'
  end

  if win and vim.api.nvim_win_is_valid(win) then
    local width = vim.api.nvim_win_get_width(win)
    local display = vim.fn.strdisplaywidth(text)
    local pad = width - display
    if pad > 0 then
      opts.virt_text = { { string.rep(' ', pad), 'NeoTreeCursorLine' } }
      opts.virt_text_win_col = display
      opts.virt_text_pos = 'overlay'
    end
  end

  vim.api.nvim_buf_set_extmark(buf, select_ns, line - 1, 0, opts)
end

local function paint_from_win(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].filetype ~= 'neo-tree' then
    return
  end
  local ok, cursor = pcall(vim.api.nvim_win_get_cursor, win)
  if ok then
    paint_selection(buf, cursor[1], win)
  end
end

require('neo-tree').setup {
  enable_git_status = false,
  default_component_configs = {
    icon = {
      folder_closed = ' ',
      folder_open = ' ',
      folder_empty = '',
      default = '',
    },
    name = { use_git_status_colors = false },
    git_status = {
      symbols = {
        added = '',
        deleted = '',
        modified = '',
        renamed = '',
        untracked = '',
        ignored = '',
        unstaged = '',
        staged = '',
        conflict = '',
      },
    },
  },
  window = {
    mappings = {
      ['\\'] = 'close_window',
      ['<cr>'] = 'open',
      ['l'] = 'open',
      ['h'] = function(state)
        local node = state.tree:get_node()
        if node.type == 'directory' and node:is_expanded() then
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
  event_handlers = {
    {
      event = 'neo_tree_window_after_open',
      handler = function(args)
        if args.winid and vim.api.nvim_win_is_valid(args.winid) then
          vim.wo[args.winid].cursorline = false
          paint_from_win(args.winid)
        end
      end,
    },
    {
      event = 'after_render',
      handler = function(state)
        local buf = state.bufnr
        if not buf or not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        local line = vim.b[buf].neo_tree_selected_line
        local win = state.winid
        if (not line or line < 1) and win and vim.api.nvim_win_is_valid(win) then
          local ok, cursor = pcall(vim.api.nvim_win_get_cursor, win)
          if ok then
            line = cursor[1]
          end
        end
        if line then
          paint_selection(buf, line, win)
        end
      end,
    },
  },
}

neo_tree_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('neo-tree-eternal-hl', { clear = true }),
  callback = neo_tree_highlights,
})

vim.api.nvim_create_autocmd({ 'CursorMoved', 'BufEnter', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('neo-tree-selection-paint', { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype ~= 'neo-tree' then
      return
    end
    vim.wo.cursorline = false
    paint_from_win(vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd('WinLeave', {
  group = vim.api.nvim_create_augroup('neo-tree-selection-keep', { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype ~= 'neo-tree' then
      return
    end
    paint_from_win(vim.api.nvim_get_current_win())
  end,
})
