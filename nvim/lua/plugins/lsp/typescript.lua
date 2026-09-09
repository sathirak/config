-- lsp/typescript: ts_ls for JavaScript and TypeScript
return {
  servers = {
    ts_ls = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
      },
      root_markers = {
        'package.json',
        'tsconfig.json',
        'jsconfig.json',
      },
    },
  },
}
