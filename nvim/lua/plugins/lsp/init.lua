-- lsp: mason bootstrap + per-language modules
local gh = require('util').gh

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

---@type table<string, vim.lsp.Config>
local servers = {}
---@type string[]
local tools = {}

local skip = { ['init.lua'] = true, ['keybindings.lua'] = true }
local lang_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'plugins', 'lsp')
for name, ftype in vim.fs.dir(lang_dir) do
  if (ftype == 'file' or ftype == 'link') and name:match '%.lua$' and not skip[name] then
    local mod = require('plugins.lsp.' .. (name:gsub('%.lua$', '')))
    servers = vim.tbl_extend('force', servers, mod.servers or {})
    tools = vim.list_extend(tools, mod.tools or {})
  end
end

require('mason').setup {}
require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
}
require('mason-tool-installer').setup {
  ensure_installed = tools,
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

require 'plugins.lsp.keybindings'

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
