return {
  "SmiteshP/nvim-navbuddy",
  dependencies = {
    "neovim/nvim-lspconfig",
    "SmiteshP/nvim-navic",
    "MunifTanjim/nui.nvim",
  },
  opts = function()
    local actions = require("nvim-navbuddy.actions")

    return {
      lsp = { auto_attach = true },

      window = {
        sections = {
          left = {
            size = "20%",
            border = nil,
          },
          mid = {
            size = "30%",
            border = nil,
          },
          right = {
            size = "50%",
            border = nil,
            preview = "always",
          },
        },
        width = "80%",
      },

      node_markers = {
        enabled = true,
        icons = {
          leaf = "",
          leaf_selected = "",
          branch = " ",
        },
      },

      mappings = {
        ["<Left>"] = actions.parent(), -- Move to left panel
        ["<Right>"] = actions.children(), -- Move to right panel
      },

      use_default_mappings = true,
    }
  end,
  keys = {
    { "<leader>n", "<cmd>Navbuddy<CR>", desc = "Open Navbuddy" },
  },
}
