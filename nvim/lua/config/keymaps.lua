-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Override <space>n for Navbuddy (LazyVim default uses it for notifications)
-- Use Lua require so the plugin loads on first use (lazy-loaded)
vim.keymap.set("n", "<leader>n", function()
  require("nvim-navbuddy").open()
end, { desc = "Navbuddy" })

-- Cycle through ayu variants (ayu, ayu-dark, ayu-mirage, ayu-light)
local ayu_styles = { "ayu", "ayu-dark", "ayu-mirage", "ayu-light" }
vim.keymap.set("n", "<leader>ut", function()
  local current = vim.g.colors_name or "ayu"
  local idx = 1
  for i, name in ipairs(ayu_styles) do
    if name == current then
      idx = i
      break
    end
  end
  idx = (idx % #ayu_styles) + 1
  local next_style = ayu_styles[idx]
  vim.cmd.colorscheme(next_style)
  vim.notify("Colorscheme: " .. next_style, vim.log.levels.INFO, { title = "Ayu" })
end, { desc = "Cycle ayu colorscheme" })

-- Ghostty + Neovim: ayu-light (light) / ayu-dark (dark); see ~/.config/bin/toggle-appearance
vim.keymap.set("n", "<leader>ub", function()
  local script = vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h") .. "/bin/toggle-appearance"
  if vim.fn.executable(script) ~= 1 then
    vim.notify("Missing executable: " .. script, vim.log.levels.ERROR)
    return
  end
  local skip = vim.v.servername ~= "" and vim.v.servername or "none"
  local out = vim.fn.system({ script, "from-nvim", skip })
  local cs = vim.trim(out or "")
  if cs == "ayu-light" or cs == "ayu-dark" then
    vim.cmd.colorscheme(cs)
    vim.notify("Appearance: " .. cs, vim.log.levels.INFO, { title = "Theme" })
  end
end, { desc = "Toggle light/dark (Dawnfox/Carbonfox)" })
