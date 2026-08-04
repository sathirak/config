-- keymaps: global bindings, plugin shortcuts, and LSP mappings
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function bufmap(buf, mode, lhs, rhs, opts)
  opts = opts or {}
  opts.buffer = buf
  map(mode, lhs, rhs, opts)
end

local float_opts = { border = 'rounded' }

map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic quickfix' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper' })

map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

map('n', '<leader>-', '<C-W>s', { desc = 'Split Window Below', remap = true })
map('n', '<leader>|', '<C-W>v', { desc = 'Split Window Right', remap = true })
map('n', '<leader>wd', '<C-W>c', { desc = 'Delete Window', remap = true })

map('n', 'J', function()
  vim.diagnostic.open_float {
    scope = 'line',
    focus = false,
    border = 'rounded',
    source = 'if_many',
  }
end, { desc = 'Line Diagnostics' })

map({ 'n', 'i', 'v' }, '<C-s>', '<Cmd>wall<CR>', { desc = 'Save all files' })

map('n', '<leader>f', function()
  require('conform').format { async = true }
end, { desc = 'Format buffer' })

local function telescope()
  return require 'telescope.builtin'
end

map('n', '<leader>sa', function()
  telescope().builtin()
end, { desc = 'Search all pickers' })
map('n', '<leader>r', function()
  telescope().resume()
end, { desc = 'Resume last search' })

map('n', '<leader>sf', function()
  telescope().find_files()
end, { desc = 'Search files' })
map('n', '<leader>sg', function()
  telescope().live_grep()
end, { desc = 'Search grep' })
map({ 'n', 'v' }, '<leader>sw', function()
  telescope().grep_string()
end, { desc = 'Search word' })
map('n', '<leader>sb', function()
  telescope().buffers()
end, { desc = 'Search buffers' })
map('n', '<leader><leader>', function()
  telescope().buffers()
end, { desc = 'Search buffers' })
map('n', '<leader>s.', function()
  telescope().oldfiles()
end, { desc = 'Search recent files' })
map('n', '<leader>/', function()
  telescope().current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Search in buffer' })
map('n', '<leader>s/', function()
  telescope().live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = 'Search in open buffers' })
map('n', '<leader>sn', function()
  telescope().find_files { cwd = vim.fn.stdpath 'config', follow = true }
end, { desc = 'Search neovim config' })

map('n', '<leader>sh', function()
  telescope().help_tags()
end, { desc = 'Search help' })
map('n', '<leader>sk', function()
  telescope().keymaps()
end, { desc = 'Search keymaps' })
map('n', '<leader>sc', function()
  telescope().commands()
end, { desc = 'Search commands' })
map('n', '<leader>ss', function()
  telescope().lsp_document_symbols()
end, { desc = 'Search document symbols' })
map('n', '<leader>sS', function()
  telescope().lsp_dynamic_workspace_symbols()
end, { desc = 'Search workspace symbols' })
map('n', '<leader>sr', function()
  telescope().lsp_references()
end, { desc = 'Search references' })
map('n', '<leader>sd', function()
  telescope().diagnostics()
end, { desc = 'Search diagnostics' })

map('n', 's', function()
  require('flash').jump()
end, { desc = 'Flash' })
map('n', 'S', function()
  require('flash').treesitter()
end, { desc = 'Flash Treesitter' })
map('o', 'r', function()
  require('flash').remote()
end, { desc = 'Remote Flash' })
map({ 'o', 'x' }, 'R', function()
  require('flash').treesitter_search()
end, { desc = 'Treesitter Search' })
map('c', '<C-s>', function()
  require('flash').toggle()
end, { desc = 'Toggle Flash Search' })

map('n', '\\', '<Cmd>Neotree reveal<CR>', { desc = 'NeoTree reveal' })
map('n', '<leader>n', '<cmd>Navbuddy<cr>', { desc = 'Navbuddy' })

map('n', '<leader>qs', function()
  require('plugins.ui.session').restore()
end, { desc = 'Restore Session' })
map('n', '<leader>qd', function()
  require('plugins.ui.session').delete()
end, { desc = 'Delete Session' })

map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
map('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })
map('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
map('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dashboard-keymaps', { clear = true }),
  pattern = 'dashboard',
  callback = function(event)
    bufmap(event.buf, 'n', 's', function()
      require('plugins.ui.session').restore()
    end, { desc = 'Restore session', silent = true })
  end,
})

local function supports(client, method, buf)
  method = method:find '/' and method or ('textDocument/' .. method)
  return client:supports_method(method, buf)
end

local function on_attach(client, buf)
  if supports(client, 'definition', buf) then
    bufmap(buf, 'n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
  end
  bufmap(buf, 'n', 'gr', vim.lsp.buf.references, { desc = 'References', nowait = true })
  bufmap(buf, 'n', 'gI', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
  bufmap(buf, 'n', 'gy', vim.lsp.buf.type_definition, { desc = 'Goto Type Definition' })
  bufmap(buf, 'n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })

  bufmap(buf, 'n', 'K', function()
    return vim.lsp.buf.hover(float_opts)
  end, { desc = 'Hover' })
  if supports(client, 'signatureHelp', buf) then
    bufmap(buf, 'n', 'gK', function()
      return vim.lsp.buf.signature_help(float_opts)
    end, { desc = 'Signature Help' })
    bufmap(buf, 'i', '<C-k>', function()
      return vim.lsp.buf.signature_help(float_opts)
    end, { desc = 'Signature Help' })
  end

  bufmap(buf, 'n', '<leader>cl', '<cmd>checkhealth vim.lsp<cr>', { desc = 'Lsp Info' })
  if supports(client, 'codeAction', buf) then
    bufmap(buf, { 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
    bufmap(buf, 'n', '<leader>cA', function()
      vim.lsp.buf.code_action {
        apply = true,
        context = { only = { 'source' }, diagnostics = {} },
      }
    end, { desc = 'Source Action' })
    bufmap(buf, 'n', '<leader>co', function()
      vim.lsp.buf.code_action {
        apply = true,
        context = { only = { 'source.organizeImports' }, diagnostics = {} },
      }
    end, { desc = 'Organize Imports' })
  end
  if supports(client, 'codeLens', buf) then
    bufmap(buf, { 'n', 'x' }, '<leader>cc', vim.lsp.codelens.run, { desc = 'Run Codelens' })
    bufmap(buf, 'n', '<leader>cC', vim.lsp.codelens.refresh, { desc = 'Refresh Codelens' })
  end
  if supports(client, 'rename', buf) then
    bufmap(buf, 'n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename' })
  end
  if supports(client, 'workspace/didRenameFiles', buf) or supports(client, 'workspace/willRenameFiles', buf) then
    bufmap(buf, 'n', '<leader>cR', function()
      local old = vim.api.nvim_buf_get_name(buf)
      vim.ui.input({ prompt = 'New filename: ', default = old }, function(new)
        if not new or new == '' or new == old then
          return
        end
        vim.fn.mkdir(vim.fn.fnamemodify(new, ':h'), 'p')
        vim.cmd.write()
        local ok, err = os.rename(old, new)
        if not ok then
          vim.notify('Rename failed: ' .. tostring(err), vim.log.levels.ERROR)
          return
        end
        vim.cmd.edit(new)
        vim.cmd 'silent! bwipeout! #'
      end)
    end, { desc = 'Rename File' })
  end
  if supports(client, 'inlayHint', buf) then
    bufmap(buf, 'n', '<leader>uh', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
    end, { desc = 'Toggle Inlay Hints' })
  end
end

vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Next Diagnostic' })
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Prev Diagnostic' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Next Error' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Prev Error' })
vim.keymap.set('n', ']w', function()
  vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.WARN }
end, { desc = 'Next Warning' })
vim.keymap.set('n', '[w', function()
  vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.WARN }
end, { desc = 'Prev Warning' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-keybindings', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client then
      on_attach(client, event.buf)
    end
  end,
})

local keymaps = {}

function keymaps.neo_tree_window_mappings()
  return {
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
  }
end

function keymaps.neo_tree_filesystem_window_mappings()
  return {
    ['<bs>'] = 'navigate_up',
    ['.'] = 'set_root',
    ['H'] = 'toggle_hidden',
    ['I'] = function(state)
      state.filtered_items.hide_gitignored = not state.filtered_items.hide_gitignored
      require('neo-tree.sources.manager').refresh(state.name)
    end,
  }
end

function keymaps.navbuddy_mappings()
  local actions = require 'nvim-navbuddy.actions'
  return {
    ['<Left>'] = actions.parent(),
    ['<Right>'] = actions.children(),
    ['h'] = actions.parent(),
    ['l'] = actions.children(),
  }
end

function keymaps.telescope_mappings()
  return {
    i = {
      ['<C-/>'] = require('telescope.actions.layout').toggle_preview,
    },
    n = {
      ['<C-/>'] = require('telescope.actions.layout').toggle_preview,
    },
  }
end

return keymaps
