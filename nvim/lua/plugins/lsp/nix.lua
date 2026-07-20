-- lsp/nix: nil (flake-aware) + nixfmt
return {
  servers = {
    nil_ls = {
      settings = {
        ['nil'] = {
          formatting = {
            command = { 'nixfmt' },
          },
          nix = {
            flake = {
              autoArchive = true,
              autoEvalInputs = true,
            },
          },
        },
      },
    },
  },
}
