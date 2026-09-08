-- lsp/python: basedpyright (types) + ruff (lint/format)
return {
  servers = {
    basedpyright = {
      settings = {
        basedpyright = {
          disableOrganizeImports = true,
          analysis = {
            autoImportCompletions = true,
            typeCheckingMode = 'standard',
          },
        },
      },
    },
    ruff = {
      on_attach = function(client)
        -- basedpyright owns hover
        client.server_capabilities.hoverProvider = false
      end,
    },
  },
}
