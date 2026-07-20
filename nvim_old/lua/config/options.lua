-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_picker = "snacks"

vim.opt.fillchars = {
  vert = "┃", -- Thick vertical border
  horiz = "━", -- Thick horizontal border
  verthoriz = "╋", -- Thick cross intersection
  horizup = "┻", -- Thick bottom T-junction
  horizdown = "┳", -- Thick top T-junction
  vertleft = "┫", -- Thick right T-junction
  vertright = "┣", -- Thick left T-junction
}

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    -- Links your borders to your theme's line number color (usually a clean, subtle gray/blue)
    vim.api.nvim_set_hl(0, "WinSeparator", { link = "LineNr" })
  end,
})

-- Run it immediately for the current session
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#ff007c", bg = "none" })

-- Maps Normal/Command mode to 'Cursor', and forces Visual mode to use 'VisualCursor'
vim.opt.guicursor =
  "n-c:block-Cursor,v:block-VisualCursor,i-ci-ve:ver25-Cursor,r-cr:hor20,o:blinkwait700-blinkoff400-blinkon250"
