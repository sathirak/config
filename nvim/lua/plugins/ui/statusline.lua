-- statusline: branch | file | scope  ===  C-o | C-i
local M = {}

vim.o.laststatus = 3

local I = {
  branch = '\u{f418}',
  file = '\u{f4a5}',
  fn = '\u{f45f}',
  older = '\u{f060}',
  newer = '\u{f061}',
}

local W = {
  branch = 36,
  file = 22,
  fn = 28,
  jump = 16,
}

local c = {
  bg = '#030406',
  fg = '#cdd6f4',
  muted = '#6c7086',
  peach = '#fab387',
  green = '#a6e3a1',
  sky = '#89dceb',
  blue = '#89b4fa',
  mauve = '#cba6f7',
}

local function apply_highlights()
  local bg = c.bg
  vim.api.nvim_set_hl(0, 'StatusLine', { fg = c.fg, bg = bg })
  vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = c.muted, bg = bg })
  vim.api.nvim_set_hl(0, 'StBranch', { fg = c.green, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, 'StFile', { fg = c.blue, bg = bg, bold = true })
  vim.api.nvim_set_hl(0, 'StFn', { fg = c.mauve, bg = bg })
  vim.api.nvim_set_hl(0, 'StOlder', { fg = c.peach, bg = bg })
  vim.api.nvim_set_hl(0, 'StNewer', { fg = c.sky, bg = bg })
  vim.api.nvim_set_hl(0, 'StSep', { fg = c.muted, bg = bg })
end

apply_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('statusline-hl', { clear = true }),
  callback = apply_highlights,
})

pcall(function()
  require('nvim-navic').setup {
    highlight = false,
    separator = '.',
    depth_limit = 4,
    depth_limit_indicator = '..',
    lazy_update_context = true,
  }
end)

---@param text string
---@param width integer
local function fixed(text, width)
  text = text or ''
  local w = vim.fn.strdisplaywidth(text)
  if w > width then
    if width <= 1 then
      return vim.fn.strcharpart(text, 0, width)
    end
    return vim.fn.strcharpart(text, 0, math.max(width - 1, 1)) .. '…'
  end
  return text .. string.rep(' ', width - w)
end

---@param text string
local function stl_escape(text)
  return (text:gsub('%%', '%%%%'))
end

---@param hl string
---@param icon string
---@param text string
---@param width integer
local function cell(hl, icon, text, width)
  local body = fixed(icon .. ' ' .. (text ~= '' and text or '-'), width)
  return '%#' .. hl .. '#' .. stl_escape(body)
end

---@type { cwd: string, time: number, branch: string }
local git_cache = { cwd = '', time = 0, branch = '' }

local function git_branch()
  local cwd = vim.fn.getcwd()
  local now = vim.uv.now()
  if git_cache.cwd == cwd and (now - git_cache.time) < 2000 then
    return git_cache.branch
  end

  local inside = vim.fn.systemlist({ 'git', '-C', cwd, 'rev-parse', '--is-inside-work-tree' })[1]
  if vim.v.shell_error ~= 0 or inside ~= 'true' then
    git_cache = { cwd = cwd, time = now, branch = '' }
    return ''
  end

  local branch = vim.b.gitsigns_head
  if not branch or branch == '' then
    branch = vim.fn.systemlist({ 'git', '-C', cwd, 'rev-parse', '--abbrev-ref', 'HEAD' })[1] or ''
  end

  git_cache = { cwd = cwd, time = now, branch = branch }
  return branch
end

local function current_file()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    return '-'
  end
  return vim.fn.fnamemodify(name, ':t')
end

local function function_scope()
  local ok, navic = pcall(require, 'nvim-navic')
  if not ok or not navic.is_available() then
    return '-'
  end
  local loc = navic.get_location()
  if not loc or loc == '' then
    return '-'
  end
  return (loc:gsub('%%#[^#]+#', ''):gsub('%%%*', ''))
end

---@param jump table
---@return string?
local function jump_tail(jump)
  if not jump then
    return nil
  end
  local path = jump.filename
  if (not path or path == '') and jump.bufnr and vim.api.nvim_buf_is_valid(jump.bufnr) then
    path = vim.api.nvim_buf_get_name(jump.bufnr)
  end
  if not path or path == '' then
    return nil
  end
  return vim.fn.fnamemodify(path, ':t')
end

local function jump_neighbors()
  local jumps, idx = unpack(vim.fn.getjumplist())
  if not jumps or #jumps == 0 then
    return '-', '-'
  end

  local cur = idx + 1
  local here = jump_tail(jumps[cur]) or current_file()

  local older = '-'
  for i = cur - 1, 1, -1 do
    local name = jump_tail(jumps[i])
    if name and name ~= here then
      older = name
      break
    end
  end

  local newer = '-'
  for i = cur + 1, #jumps do
    local name = jump_tail(jumps[i])
    if name and name ~= here then
      newer = name
      break
    end
  end

  return older, newer
end

function M.render()
  local branch = git_branch()
  local file = current_file()
  local scope = function_scope()
  local older, newer = jump_neighbors()

  return table.concat {
    cell('StBranch', I.branch, branch ~= '' and branch or '-', W.branch),
    '%#StSep#  ',
    cell('StFile', I.file, file, W.file),
    '%#StSep#  ',
    cell('StFn', I.fn, scope, W.fn),
    '%=',
    cell('StOlder', I.older, older, W.jump),
    '%#StSep#  ',
    cell('StNewer', I.newer, newer, W.jump),
  }
end

vim.o.statusline = '%{%v:lua.require("plugins.ui.statusline").render()%}'

vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorMoved', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('statusline-refresh', { clear = true }),
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

return M
