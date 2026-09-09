-- dashboard: startup logo + live metadata
local session = require 'plugins.ui.session'

local start_hrtime = vim.uv.hrtime()

local state = {
  buf = nil,
  win = nil,
  startup_ms = nil,
  metadata = {
    loading = true,
    ---@type { left: string, right: string }[]
    rows = {},
  },
}

-- Art only — trailing spaces are stripped at render time so splits don't wrap.
local logo = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣆
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣤⣤⣀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡿⠿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣷⣄
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⣶⣶⣶⣶⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⣴⣶⣶⠀⠀⣠⣤⣶⣶⣶⣶⣶⣦⣤⡀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⡿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⡿⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⠿⠛⠛⠛⠿⢿⣿⣿⣦⡀⠀⠀⠀⠀⠀⣿⣿⣿⣦⣿⣿⠿⠟⠛⠛⠻⠿⣿⣿⣿⣦
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠁⢻⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⡿⠃⠀⠀⠀⠀⢀⣾⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣷⡀⠀⠀⠀⠀⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⡆
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠃⠀⠀⢿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⣶⣶⣶⣶⣶⣶⣿⣿⣿⡿⠛⠁⠀⠀⠀⠀⠀⣸⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠃⠀⠀⠀⠈⢿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡿⠿⠿⠿⠿⠿⣿⣿⣿⡅⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠘⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡟⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠃⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣧⠀⠀⠀⠀⠀⠀⢻⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣷⡀⠀⠀⠀⠀⠈⢿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣄⠀⠀⠀⠀⠈⠻⣿⣿⣿⣶⣤⣤⣤⣤⣤⣤⣶⣾⣿⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇
⠀⠀⣴⣾⣿⣿⣿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⣿⣿⣿⣿⣶⡄⠀⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⠿⠿⠆⠀⠀⠀⠀⠀⠈⠛⠿⠿⣿⣿⣿⣿⣿⡿⠿⠟⠋⠀⠀⠀⠀⠀⠿⠿⠿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠇
⠀⠀⠻⣿⣿⡿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⢿⣿⣿⡿⠃
]]

local DEFAULT_BLOCK_WIDTH = 76

---@return integer
local function win_width()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    return vim.api.nvim_win_get_width(state.win)
  end
  return vim.o.columns
end

---@return integer
local function win_height()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    return vim.api.nvim_win_get_height(state.win)
  end
  return vim.o.lines
end

---@return integer
local function block_width()
  return math.max(24, math.min(DEFAULT_BLOCK_WIDTH, win_width() - 4))
end

---@param lines string[]
---@return string[]
local function trim_logo_lines(lines)
  local trimmed = {}
  for _, line in ipairs(lines) do
    local clean = line:gsub('%s+$', '')
    if clean ~= '' then
      trimmed[#trimmed + 1] = clean
    end
  end
  return trimmed
end

---@param lines string[]
---@return integer
local function max_display_width(lines)
  local max = 0
  for _, line in ipairs(lines) do
    max = math.max(max, vim.fn.strdisplaywidth(line))
  end
  return max
end

-- Pad every line with the same left offset so the art stays aligned.
-- Per-line centering (based on each line's own width) scrambles block art.
---@param lines string[]
---@param width integer
---@return string[]
local function center_block(lines, width)
  local max_w = max_display_width(lines)
  local pad = math.max(0, math.floor((width - max_w) / 2))
  local left = string.rep(' ', pad)
  local centered = {}
  for _, line in ipairs(lines) do
    centered[#centered + 1] = left .. line
  end
  return centered
end

local function justify_line(left, right)
  left = left or ''
  right = right or ''
  local bw = block_width()
  local width = win_width()
  local left_width = vim.fn.strdisplaywidth(left)

  local max_right = bw - left_width - 2
  if vim.fn.strdisplaywidth(right) > max_right then
    if max_right > 1 then
      right = vim.fn.strcharpart(right, 0, max_right - 1) .. '…'
    else
      right = ''
    end
  end

  local right_width = vim.fn.strdisplaywidth(right)
  local gap = math.max(1, bw - left_width - right_width)
  local line = left .. string.rep(' ', gap) .. right

  local pad = math.max(0, math.floor((width - bw) / 2))
  return string.rep(' ', pad) .. line
end

local function block_line(text)
  text = text or ''
  local bw = block_width()
  local width = win_width()
  if vim.fn.strdisplaywidth(text) > bw then
    text = vim.fn.strcharpart(text, 0, bw - 1) .. '…'
  end

  local pad = math.max(0, math.floor((width - bw) / 2))
  return string.rep(' ', pad) .. text
end

local function format_duration(seconds)
  seconds = math.max(0, math.floor(seconds + 0.5))
  if seconds < 60 then
    return seconds .. 's'
  end

  local minutes = math.floor(seconds / 60)
  local remaining_seconds = seconds % 60
  if minutes < 60 then
    return string.format('%dm %02ds', minutes, remaining_seconds)
  end

  local hours = math.floor(minutes / 60)
  minutes = minutes % 60
  return string.format('%dh %02dm %02ds', hours, minutes, remaining_seconds)
end

local function format_elapsed(ms)
  if ms < 1000 then
    return ms .. 'ms'
  end

  local seconds = ms / 1000
  if seconds < 60 then
    return string.format('%.1fs', seconds)
  end

  return format_duration(seconds)
end

local function render_session_age()
  local stat = vim.uv.fs_stat(session.path())
  if not stat then
    return 'none'
  end

  local mtime = stat.mtime.sec + (stat.mtime.nsec / 1e9)
  return format_duration(os.time() - mtime) .. ' ago'
end

local function update_dashboard()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return
  end
  if vim.bo[state.buf].filetype ~= 'dashboard' then
    return
  end

  -- Prefer the window that still shows this buffer (splits may move focus).
  if not (state.win and vim.api.nvim_win_is_valid(state.win) and vim.api.nvim_win_get_buf(state.win) == state.buf) then
    state.win = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == state.buf then
        state.win = win
        break
      end
    end
  end

  local width = win_width()
  local height = win_height()
  local logo_lines = trim_logo_lines(vim.split(logo, '\n', { plain = true }))
  local logo_w = max_display_width(logo_lines)
  local show_logo = width >= logo_w + 2

  local rendered = {}
  local body_lines = 0
  if show_logo then
    body_lines = #logo_lines
  end
  body_lines = body_lines + 6 -- spacer + metadata block + footer estimate

  local top = math.max(0, math.floor((height - body_lines) / 2) - 1)
  for _ = 1, top do
    rendered[#rendered + 1] = ''
  end

  if show_logo then
    vim.list_extend(rendered, center_block(logo_lines, width))
    rendered[#rendered + 1] = ''
  else
    -- Narrow / split: skip art so it cannot clip mid-glyph.
    rendered[#rendered + 1] = block_line 'neptune'
    rendered[#rendered + 1] = ''
  end

  local meta_lines
  if state.metadata.loading then
    meta_lines = { block_line 'loading...' }
  else
    meta_lines = {}
    for _, row in ipairs(state.metadata.rows) do
      meta_lines[#meta_lines + 1] = justify_line(row.left, row.right)
    end
  end

  local sections = {
    {
      title = 'metadata',
      lines = meta_lines,
    },
  }

  for _, section in ipairs(sections) do
    rendered[#rendered + 1] = block_line('[ ' .. section.title .. ' ]')
    for _, line in ipairs(section.lines) do
      rendered[#rendered + 1] = line
    end
    rendered[#rendered + 1] = ''
  end

  rendered[#rendered + 1] = justify_line('press  \\  for files', 's: session')

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, rendered)
  vim.bo[state.buf].modifiable = false
  vim.bo[state.buf].modified = false
end

local function request_render()
  vim.schedule(update_dashboard)
end

local function collect_metadata(cwd)
  vim.system({ 'git', '-C', cwd, 'rev-parse', '--is-inside-work-tree' }, { text = true }, function(result)
    vim.schedule(function()
      local repo = result.code == 0 and (result.stdout or ''):match '^%s*(.-)%s*$' == 'true'
      state.metadata.loading = false
      state.metadata.rows = {
        { left = 'startup', right = format_elapsed(state.startup_ms or 0) },
        { left = 'repo', right = repo and 'git' or 'no' },
        { left = 'away', right = render_session_age() },
      }
      request_render()
    end)
  end)
end

local function open()
  if vim.fn.argc() > 0 or vim.bo.filetype ~= '' or vim.bo.modified then
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(buf) ~= '' then
    return
  end

  state.buf = buf
  state.win = vim.api.nvim_get_current_win()
  state.startup_ms = math.floor((vim.uv.hrtime() - start_hrtime) / 1e6)
  state.metadata.loading = true
  state.metadata.rows = {}

  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '' })
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
  vim.bo[buf].filetype = 'dashboard'
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'
  vim.opt_local.foldcolumn = '0'
  vim.opt_local.cursorline = false
  vim.opt_local.list = false
  vim.opt_local.wrap = false
  vim.opt_local.linebreak = false
  vim.opt_local.sidescrolloff = 0

  request_render()
  collect_metadata(vim.fn.getcwd())
end

local augroup = vim.api.nvim_create_augroup('dashboard', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = augroup,
  callback = function()
    vim.schedule(open)
  end,
})

-- Re-layout when splits/resizes change the dashboard window width.
vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized', 'WinEnter' }, {
  group = augroup,
  callback = function()
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) and vim.bo[state.buf].filetype == 'dashboard' then
      request_render()
    end
  end,
})
