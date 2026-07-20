return {
  { import = "lazyvim.plugins.extras.ui.smear-cursor" },
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      -- LazyVim defaults to "none", which samples syntax fg at the cursor.
      -- That goes white-on-white over Visual / LSP reference highlights in eternal.
      cursor_color = "Cursor",
      cursor_color_insert_mode = "Cursor",
    },
  },
}
