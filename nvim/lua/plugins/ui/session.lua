-- session: per-cwd sessions (auto-save; restore with s on dashboard)
local M = {}

local function sessions_dir()
  return vim.fs.joinpath(vim.fn.stdpath 'state', 'sessions')
end

---@param cwd? string
function M.path(cwd)
  cwd = vim.fs.normalize(cwd or vim.fn.getcwd())
  local name = cwd:gsub('[/\\:]', '%%')
  return vim.fs.joinpath(sessions_dir(), name .. '.vim')
end

---@param cwd? string
function M.exists(cwd)
  return vim.fn.filereadable(M.path(cwd)) == 1
end

local function has_file_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == '' then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' then
        return true
      end
    end
  end
  return false
end

function M.save()
  if not has_file_buffers() then
    return
  end

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
    if vim.bo[buf].filetype == 'dashboard' then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end

  local ok, err = pcall(vim.cmd.source, vim.fn.fnameescape(path))
  if not ok then
    vim.notify('Failed to restore session:\n' .. tostring(err), vim.log.levels.ERROR)
  end
end

function M.delete()
  local path = M.path()
  if vim.fn.filereadable(path) == 1 then
    vim.fn.delete(path)
  end
end

vim.opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = vim.api.nvim_create_augroup('session-autosave', { clear = true }),
  callback = function()
    M.save()
  end,
})

return M
