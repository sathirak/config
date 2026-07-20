return {
  "akinsho/bufferline.nvim",
  enabled = false,
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  opts = {
    options = {
      indicator = {
        icon = "   ",
        style = "icon",
      },
      buffer_close_icon = " ",
      modified_icon = "  ",
      close_icon = " ",
      left_trunc_marker = " ",
      right_trunc_marker = " ",
      show_buffer_close_icons = false,
      show_buffer_icons = false,
      separator_style = "thin",
      sort_by = "insert_at_end",
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        if context.buffer:current() then
          return ""
        end

        return tostring(count)
      end,
    },
  },
}
