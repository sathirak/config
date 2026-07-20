-- LazyVim's lang.markdown extra runs markdownlint-cli2 (nvim-lint) and marksman LSP — often noisy for notes.
-- If you use the none-ls extra, also filter `nls.builtins.diagnostics.markdownlint_cli2` there.
return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = {},
        ["markdown.mdx"] = {},
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
        },
      },
    },
  },
}
