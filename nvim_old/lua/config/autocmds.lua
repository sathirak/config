-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVim enables spell for markdown in lazyvim_wrap_spell; keep wrap, disable spell for notes.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_markdown_no_spell", { clear = true }),
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

local function snacks_explorer_autopen_buf(buf)
  local bo = vim.bo[buf]
  if bo.buftype ~= "" then
    return false
  end
  local ft = bo.filetype
  if ft:find("^snacks", 1, true) then
    return false
  end
  local block = {
    dashboard = true,
    snacks_dashboard = true,
    alpha = true,
    ministarter = true,
    lazy = true,
    mason = true,
    notify = true,
    qf = true,
    help = true,
    netrw = true,
    spectre_panel = true,
    PlenaryTestPopup = true,
  }
  return block[ft] ~= true
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("user_snacks_explorer_autopen", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    if not snacks_explorer_autopen_buf(buf) or vim.api.nvim_get_current_buf() ~= buf then
      return
    end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_get_current_buf() ~= buf then
        return
      end
      if not snacks_explorer_autopen_buf(buf) then
        return
      end
      if type(Snacks) ~= "table" or not Snacks.explorer then
        return
      end
      local cwd = LazyVim.root({ buf = buf })
      local existing = Snacks.picker.get({ source = "explorer" })[1]
      if existing then
        pcall(Snacks.explorer.reveal, { buf = buf })
      else
        Snacks.explorer({
          cwd = cwd,
          focus = false,
          enter = false,
        })
      end
    end)
  end,
})

-- local function clear_cmdarea()
--   vim.defer_fn(function()
--     vim.api.nvim_echo({}, false, {})
--   end, 800)
-- end
--
-- vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--   callback = function()
--     if #vim.api.nvim_buf_get_name(0) ~= 0 and vim.bo.buflisted then
--       vim.cmd("silent w")
--       clear_cmdarea()
--     end
--   end,
-- })
