-- session: per-cwd sessions (auto-save; restore with s on dashboard)
-- Neo-tree windows break under mksession, so we stash open/expanded state in
-- globals, close before save, and reopen after restore.
local M = {}

local function sessions_dir() return vim.fs.joinpath(vim.fn.stdpath 'state', 'sessions') end

---@param cwd? string
function M.path(cwd)
  cwd = vim.fs.normalize(cwd or vim.fn.getcwd())
  local name = cwd:gsub('[/\\:]', '%%')
  return vim.fs.joinpath(sessions_dir(), name .. '.vim')
end

---@param cwd? string
function M.exists(cwd) return vim.fn.filereadable(M.path(cwd)) == 1 end

local function has_file_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' then return true end
    end
  end
  return false
end

---@return boolean
local function neo_tree_is_open()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'neo-tree' then return true end
  end
  return false
end

---@return string[]
local function neo_tree_expanded_folders()
  local ok, manager = pcall(require, 'neo-tree.sources.manager')
  if not ok then return {} end
  local state = manager.get_state 'filesystem'
  if not state or not state.tree then return {} end
  local ok_r, renderer = pcall(require, 'neo-tree.ui.renderer')
  if not ok_r then return {} end
  return renderer.get_expanded_nodes(state.tree) or {}
end

local function neo_tree_capture()
  if not neo_tree_is_open() then
    vim.g.NeoTreeWasOpen = 0
    vim.g.NeoTreeExpanded = ''
    return
  end

  vim.g.NeoTreeWasOpen = 1
  local folders = neo_tree_expanded_folders()
  vim.g.NeoTreeExpanded = table.concat(folders, '\n')
  pcall(vim.cmd.Neotree, 'close')
end

local function neo_tree_restore()
  if vim.g.NeoTreeWasOpen ~= 1 then
    pcall(function() require('neo-tree.ui.renderer').clean_invalid_neotree_buffers(true) end)
    return
  end

  local expanded = {}
  if type(vim.g.NeoTreeExpanded) == 'string' and vim.g.NeoTreeExpanded ~= '' then
    for line in vim.g.NeoTreeExpanded:gmatch '[^\n]+' do
      expanded[#expanded + 1] = line
    end
  end

  vim.schedule(function()
    pcall(function() require('neo-tree.ui.renderer').clean_invalid_neotree_buffers(true) end)

    if #expanded > 0 then
      local ok, manager = pcall(require, 'neo-tree.sources.manager')
      if ok then
        local state = manager.get_state 'filesystem'
        state.force_open_folders = expanded
      end
    end

    -- show keeps focus on the restored file buffer
    pcall(vim.cmd.Neotree, 'show')
  end)
end

function M.save()
  if not has_file_buffers() then return end

  neo_tree_capture()

  vim.fn.mkdir(sessions_dir(), 'p')
  local path = M.path()
  vim.cmd.mksession { args = { vim.fn.fnameescape(path) }, bang = true }
end

function M.restore()
  local path = M.path()
  if vim.fn.filereadable(path) == 0 then
    vim.notify('No session for this directory', vim.log.levels.WARN)
    return
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == 'dashboard' then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
  end

  local ok, err = pcall(vim.cmd.source, vim.fn.fnameescape(path))
  if not ok then
    vim.notify('Failed to restore session:\n' .. tostring(err), vim.log.levels.ERROR)
    return
  end

  neo_tree_restore()
end

function M.delete()
  local path = M.path()
  if vim.fn.filereadable(path) == 1 then vim.fn.delete(path) end
  vim.g.NeoTreeWasOpen = nil
  vim.g.NeoTreeExpanded = nil
end

-- uppercase globals are required for sessionoptions+=globals
vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('session-autosave', { clear = true }),
  callback = function() M.save() end,
})

return M
