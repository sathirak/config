-- dashboard: startup logo + live metadata
local session = require 'plugins.ui.session'

local start_hrtime = vim.uv.hrtime()

local state = {
  buf = nil,
  startup_ms = nil,
  metadata = {
    loading = true,
    lines = { 'checking startup metadata...' },
  },
}

local logo = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣤⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡿⠿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣶⣶⣶⣶⣶⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⣴⣶⣶⠀⠀⣠⣤⣶⣶⣶⣶⣶⣦⣤⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⡿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⡿⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⠿⠛⠛⠛⠿⢿⣿⣿⣦⡀⠀⠀⠀⠀⠀⣿⣿⣿⣦⣿⣿⠿⠟⠛⠛⠻⠿⣿⣿⣿⣦⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⠁⢻⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⡿⠃⠀⠀⠀⠀⢀⣾⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣷⡀⠀⠀⠀⠀⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⡆⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠃⠀⠀⢿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⣶⣶⣶⣶⣶⣶⣿⣿⣿⡿⠛⠁⠀⠀⠀⠀⠀⣸⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠃⠀⠀⠀⠈⢿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡿⠿⠿⠿⠿⠿⣿⣿⣿⡅⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠘⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡟⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠃⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣧⠀⠀⠀⠀⠀⠀⢻⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣷⡀⠀⠀⠀⠀⠈⢿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣄⠀⠀⠀⠀⠈⠻⣿⣿⣿⣶⣤⣤⣤⣤⣤⣤⣶⣾⣿⠀⠀⠀⠀⠀⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀
⠀⠀⣴⣾⣿⣿⣿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⣿⣿⣿⣿⣶⡄⠀⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⠿⠿⠆⠀⠀⠀⠀⠀⠈⠛⠿⠿⣿⣿⣿⣿⣿⡿⠿⠟⠋⠀⠀⠀⠀⠀⠿⠿⠿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠇⠀⠀⠀
⠀⠀⠻⣿⣿⡿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⢿⣿⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]

local block_width = 76 -- Static width, smaller than the logo size, frames data neatly.

local function center(lines)
  local width = vim.o.columns
  local centered = {}
  for _, line in ipairs(lines) do
    local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(line)) / 2))
    table.insert(centered, string.rep(' ', pad) .. line)
  end
  return centered
end

-- Generates a left/right justified row mapped to the block width and then centers the block on screen
local function justify_line(left, right)
  left = left or ''
  right = right or ''
  local left_width = vim.fn.strdisplaywidth(left)

  -- Truncate right side if the text overflows
  local max_right = block_width - left_width - 2
  if vim.fn.strdisplaywidth(right) > max_right then
    if max_right > 1 then
      right = vim.fn.strcharpart(right, 0, max_right - 1) .. '…'
    else
      right = ''
    end
  end

  local right_width = vim.fn.strdisplaywidth(right)
  local gap = math.max(1, block_width - left_width - right_width)
  local line = left .. string.rep(' ', gap) .. right

  local pad = math.max(0, math.floor((vim.o.columns - block_width) / 2))
  return string.rep(' ', pad) .. line
end

-- Generates a single left-aligned row mapped to the block width and centers the block on screen
local function block_line(text)
  text = text or ''
  local display_width = vim.fn.strdisplaywidth(text)
  if display_width > block_width then text = vim.fn.strcharpart(text, 0, block_width - 1) .. '…' end

  local pad = math.max(0, math.floor((vim.o.columns - block_width) / 2))
  return string.rep(' ', pad) .. text
end

local function format_duration(seconds)
  seconds = math.max(0, math.floor(seconds + 0.5))
  if seconds < 60 then return seconds .. 's' end

  local minutes = math.floor(seconds / 60)
  local remaining_seconds = seconds % 60
  if minutes < 60 then return string.format('%dm %02ds', minutes, remaining_seconds) end

  local hours = math.floor(minutes / 60)
  minutes = minutes % 60
  return string.format('%dh %02dm %02ds', hours, minutes, remaining_seconds)
end

local function format_elapsed(ms)
  if ms < 1000 then return ms .. 'ms' end

  local seconds = ms / 1000
  if seconds < 60 then return string.format('%.1fs', seconds) end

  return format_duration(seconds)
end

local function render_session_age()
  local stat = vim.uv.fs_stat(session.path())
  if not stat then return 'none' end

  local mtime = stat.mtime.sec + (stat.mtime.nsec / 1e9)
  return format_duration(os.time() - mtime) .. ' ago'
end

local function update_dashboard()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  if vim.bo[state.buf].filetype ~= 'dashboard' then return end

  local content = vim.split(logo, '\n', { plain = true })
  while content[1] == '' do
    table.remove(content, 1)
  end
  while content[#content] == '' do
    table.remove(content)
  end

  local height = vim.o.lines
  local top = math.max(0, math.floor((height - #content) / 2) - 2)
  local rendered = {}
  for _ = 1, top do
    rendered[#rendered + 1] = ''
  end

  vim.list_extend(rendered, center(content))
  rendered[#rendered + 1] = ''

  local sections = {
    {
      title = 'metadata',
      lines = state.metadata.loading and { block_line 'loading...' } or state.metadata.lines,
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

local function request_render() vim.schedule(update_dashboard) end

local function collect_metadata(cwd)
  vim.system({ 'git', '-C', cwd, 'rev-parse', '--is-inside-work-tree' }, { text = true }, function(result)
    vim.schedule(function()
      local repo = result.code == 0 and (result.stdout or ''):match '^%s*(.-)%s*$' == 'true'
      state.metadata.loading = false
      state.metadata.lines = {
        justify_line('startup', format_elapsed(state.startup_ms or 0)),
        justify_line('repo', repo and 'git' or 'no'),
        justify_line('away', render_session_age()),
      }
      request_render()
    end)
  end)
end

local function open()
  if vim.fn.argc() > 0 or vim.bo.filetype ~= '' or vim.bo.modified then return end

  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_get_name(buf) ~= '' then return end

  state.buf = buf
  state.startup_ms = math.floor((vim.uv.hrtime() - start_hrtime) / 1e6)
  state.metadata.loading = true
  state.metadata.lines = { block_line 'checking startup metadata...' }

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

  request_render()
  collect_metadata(vim.fn.getcwd())
end

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('dashboard', { clear = true }),
  callback = function() vim.schedule(open) end,
})
