return {
  {
    -- show floating diagnostics on Shift +J
    "neovim/nvim-lspconfig",
    keys = {
      {
        "J",
        function()
          vim.diagnostic.open_float(nil, { focus = false })
        end,
        mode = "n",
        desc = "Show Floating Diagnostic",
      },
    },
  },
}
