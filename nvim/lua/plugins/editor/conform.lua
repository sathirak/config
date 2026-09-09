-- conform: formatting via Nix-provided CLIs; LSP fallback otherwise
local gh = require('util').gh

vim.pack.add { gh 'stevearc/conform.nvim' }
require('conform').setup {
  notify_on_error = false,
  default_format_opts = {
    lsp_format = 'fallback',
    timeout_ms = 1000,
  },
  formatters = {
    fish_indent = {
      command = 'fish_indent',
      stdin = true,
    },
  },
  formatters_by_ft = {
    bzl = { 'buildifier' },
    python = { 'ruff_organize_imports', 'ruff_format' },
    lua = { 'stylua' },
    nix = { 'nixfmt' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    fish = { 'fish_indent' },
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    json = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'prettierd', 'prettier', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
  },
}
