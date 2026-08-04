-- lsp: Nix-managed servers + per-language modules
local gh = require('util').gh

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
}

---@type table<string, vim.lsp.Config>
local servers = {}

local skip = { ['init.lua'] = true, ['keybindings.lua'] = true }
local lang_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'plugins', 'lsp')
for name, ftype in vim.fs.dir(lang_dir) do
  if (ftype == 'file' or ftype == 'link') and name:match '%.lua$' and not skip[name] then
    local mod = require('plugins.lsp.' .. (name:gsub('%.lua$', '')))
    servers = vim.tbl_extend('force', servers, mod.servers or {})
  end
end

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    if not client:supports_method('textDocument/documentHighlight', event.buf) then
      return
    end

    local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })
    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
      end,
    })
  end,
})
