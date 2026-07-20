-- lsp/rust: rust-analyzer
return {
  servers = {
    rust_analyzer = {
      settings = {
        ['rust-analyzer'] = {
          check = { command = 'check' },
          cargo = { allFeatures = true },
        },
      },
    },
  },
}
