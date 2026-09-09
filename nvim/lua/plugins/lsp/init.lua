-- lsp: Nix-managed servers + per-language modules
local gh = require('util').gh

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
}

---@type table<string, vim.lsp.Config>
local servers = {}
---@type table<string, fun(client: vim.lsp.Client, bufnr: integer)>
local on_attach_hooks = {}

local skip = { ['init.lua'] = true }
local lang_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'plugins', 'lsp')
for name, ftype in vim.fs.dir(lang_dir) do
  if (ftype == 'file' or ftype == 'link') and name:match '%.lua$' and not skip[name] then
    local ok, mod = pcall(require, 'plugins.lsp.' .. (name:gsub('%.lua$', '')))
    if ok then
      servers = vim.tbl_extend('force', servers, mod.servers or {})
    else
      vim.notify(('Failed to load LSP module %s:\n%s'):format(name, mod), vim.log.levels.ERROR)
    end
  end
end

for name, config in pairs(servers) do
  -- Native vim.lsp.config ignores lspconfig-style on_attach; handle via autocmd.
  local cfg = vim.deepcopy(config)
  if cfg.on_attach then
    on_attach_hooks[name] = cfg.on_attach
    cfg.on_attach = nil
  end
  vim.lsp.config(name, cfg)
  vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-server-on-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end
    local hook = on_attach_hooks[client.name]
    if hook then hook(client, event.buf) end
  end,
})

-- One detach handler for all buffers (never recreate with clear=true per attach).
local lsp_detach = vim.api.nvim_create_augroup('lsp-detach', { clear = true })
vim.api.nvim_create_autocmd('LspDetach', {
  group = lsp_detach,
  callback = function(event)
    vim.lsp.buf.clear_references()
    vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event.buf }
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end

    if not client:supports_method('textDocument/documentHighlight', event.buf) then return end

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
  end,
})
