-- lsp/keybindings: LazyVim-style LSP + diagnostic maps
local function map(buf, mode, lhs, rhs, opts)
  opts = opts or {}
  opts.buffer = buf
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

---@param client vim.lsp.Client
---@param method string
---@param buf integer
local function supports(client, method, buf)
  method = method:find '/' and method or ('textDocument/' .. method)
  return client:supports_method(method, buf)
end

---@param client vim.lsp.Client
---@param buf integer
local function on_attach(client, buf)
  if supports(client, 'definition', buf) then
    map(buf, 'n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
  end
  map(buf, 'n', 'gr', vim.lsp.buf.references, { desc = 'References', nowait = true })
  map(buf, 'n', 'gI', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
  map(buf, 'n', 'gy', vim.lsp.buf.type_definition, { desc = 'Goto Type Definition' })
  map(buf, 'n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })

  map(buf, 'n', 'K', function()
    return vim.lsp.buf.hover()
  end, { desc = 'Hover' })
  if supports(client, 'signatureHelp', buf) then
    map(buf, 'n', 'gK', function()
      return vim.lsp.buf.signature_help()
    end, { desc = 'Signature Help' })
    map(buf, 'i', '<C-k>', function()
      return vim.lsp.buf.signature_help()
    end, { desc = 'Signature Help' })
  end

  map(buf, 'n', '<leader>cl', '<cmd>checkhealth vim.lsp<cr>', { desc = 'Lsp Info' })
  if supports(client, 'codeAction', buf) then
    map(buf, { 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
    map(buf, 'n', '<leader>cA', function()
      vim.lsp.buf.code_action {
        apply = true,
        context = { only = { 'source' }, diagnostics = {} },
      }
    end, { desc = 'Source Action' })
    map(buf, 'n', '<leader>co', function()
      vim.lsp.buf.code_action {
        apply = true,
        context = { only = { 'source.organizeImports' }, diagnostics = {} },
      }
    end, { desc = 'Organize Imports' })
  end
  if supports(client, 'codeLens', buf) then
    map(buf, { 'n', 'x' }, '<leader>cc', vim.lsp.codelens.run, { desc = 'Run Codelens' })
    map(buf, 'n', '<leader>cC', vim.lsp.codelens.refresh, { desc = 'Refresh Codelens' })
  end
  if supports(client, 'rename', buf) then
    map(buf, 'n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename' })
  end
  if supports(client, 'workspace/didRenameFiles', buf) or supports(client, 'workspace/willRenameFiles', buf) then
    map(buf, 'n', '<leader>cR', function()
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
    map(buf, 'n', '<leader>uh', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
    end, { desc = 'Toggle Inlay Hints' })
  end
end

local function diagnostic_goto(next, severity)
  return function()
    vim.diagnostic.jump {
      count = next and 1 or -1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
    }
  end
end

vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
vim.keymap.set('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
vim.keymap.set('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
vim.keymap.set('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
vim.keymap.set('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
vim.keymap.set('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
vim.keymap.set('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-keybindings', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client then
      on_attach(client, event.buf)
    end
  end,
})
