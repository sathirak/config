return {
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    event = "BufEnter",
    opts = {
      default_mappings = false,
    },
    keys = {
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", mode = "n", desc = "Goto preview definition" },
      { "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", mode = "n", desc = "Goto preview type definition" },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", mode = "n", desc = "Goto preview implementation" },
      { "gpD", "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>", mode = "n", desc = "Goto preview declaration" },
      { "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", mode = "n", desc = "Close all preview windows" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", mode = "n", desc = "Goto preview references" },
    },
  },
}
