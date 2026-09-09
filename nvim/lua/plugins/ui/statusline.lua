local M = {}

vim.o.laststatus = 3

local function stl_escape(text)
  -- Safety check: if text is nil or not a string, return an empty string
  if not text or type(text) ~= 'string' then return '' end
  return (text:gsub('%%', '%%%%'))
end

local git_cache = { cwd = '', time = 0, branch = '', worktree = '' }

local function git_info()
  local cwd = vim.fn.getcwd()
  local now = vim.uv.now()
  if git_cache.cwd == cwd and (now - git_cache.time) < 2000 then return git_cache.branch, git_cache.worktree end

  local inside = vim.fn.systemlist({ 'git', '-C', cwd, 'rev-parse', '--is-inside-work-tree' })[1]
  if vim.v.shell_error ~= 0 or inside ~= 'true' then
    git_cache = { cwd = cwd, time = now, branch = '', worktree = '' }
    return '', ''
  end

  local branch = vim.b.gitsigns_head
  if type(branch) ~= 'string' or branch == '' then branch = vim.fn.systemlist({ 'git', '-C', cwd, 'rev-parse', '--abbrev-ref', 'HEAD' })[1] or '' end

  local toplevel = vim.fn.systemlist({ 'git', '-C', cwd, 'rev-parse', '--show-toplevel' })[1] or ''
  local worktree = ''
  if toplevel ~= '' then worktree = vim.fn.fnamemodify(toplevel, ':t') end

  git_cache = { cwd = cwd, time = now, branch = branch, worktree = worktree }
  return branch, worktree
end

local function filetype_text()
  -- Fallback to 'None' if ft is nil or empty
  local ft = vim.bo.filetype
  if not ft or ft == '' then return 'None' end
  return ft
end

-- Systemized UI configuration for LSP
local LSP_STATES = {
  active = { text = 'LSP Active', icon = ' ', hl = 'String' }, -- Usually Green/Teal
  working = { text = 'LSP Loading', icon = ' ', hl = 'WarningMsg' }, -- Usually Yellow/Orange
  offline = { text = 'LSP Inactive', icon = ' ', hl = 'ErrorMsg' }, -- Usually Grey/Muted
}

local function lsp_status(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients == 0 then return LSP_STATES.offline end

  local status = vim.lsp.status and vim.lsp.status() or ''
  local lower = status:lower()

  if lower:find('error', 1, true) or lower:find('fail', 1, true) then return LSP_STATES.offline end
  if status ~= '' then return LSP_STATES.working end

  return LSP_STATES.active
end

function M.render()
  local bufnr = vim.api.nvim_get_current_buf()
  local branch, worktree = git_info()
  local lsp = lsp_status(bufnr)
  local filetype = filetype_text()

  -- Format components with spacing and dynamic colors
  local branch_ui = (branch and branch ~= '') and ('%#Function#  ' .. stl_escape(branch) .. ' ') or ''
  local worktree_ui = (worktree and worktree ~= '') and ('%#Comment#  ' .. stl_escape(worktree) .. ' ') or ''
  local lsp_ui = string.format('%%#%s# %s %s %%#StatusLine#', lsp.hl, lsp.icon, lsp.text)
  local filetype_ui = '%#Type#  ' .. stl_escape(filetype) .. ' '

  return table.concat {
    '%#StatusLine#',
    branch_ui,
    worktree_ui,
    '%=', -- Right align the rest
    lsp_ui,
    '  ', -- Clean spacing between LSP and Filetype
    filetype_ui,
    ' ', -- Right padding
  }
end

vim.o.statusline = '%{%v:lua.require("plugins.ui.statusline").render()%}'

vim.api.nvim_create_autocmd({
  'BufEnter',
  'WinEnter',
  'DirChanged',
  'FileType',
  'LspAttach',
  'LspDetach',
  'LspProgress',
  'DiagnosticChanged',
  'User',
}, {
  group = vim.api.nvim_create_augroup('statusline-refresh', { clear = true }),
  callback = function(event)
    if event.event == 'User' and event.match ~= 'GitSignsUpdate' then return end
    vim.cmd.redrawstatus()
  end,
})

return M
