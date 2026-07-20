vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "eternal"

local lush = require("lush")
local theme = require("lush_theme.eternal")

lush(theme)
