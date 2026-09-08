-- mimir: custom dashbaord built for future use 
local M = {}

local FT = 'mimir'

---@class MimirConfig
---@field width integer
local config = {
  width = 30,
}

---@type integer[]
local bufs = {}
---@type integer[]
local wins = {}

local function apply_highlights()
  local bg = '#08090c'
  vim.api.nvim_set_hl(0, 'MimirNormal', { fg = bg, bg = bg })
end

apply_highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('mimir-hl', { clear = true }),
  callback = apply_highlights,
})

---@param opts? MimirConfig
function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
end

---@return integer
function M.width()
  return config.width
end

---@param width integer
function M.set_width(width)
  config.width = width
  if M.is_open() then
    for _, w in ipairs(wins) do
      if vim.api.nvim_win_is_valid(w) then
        vim.api.nvim_win_set_width(w, config.width)
      end
    end
  end
end

---@return boolean
function M.is_open()
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_is_valid(w) then
      return true
    end
  end
  return false
end

local function make_buf(index)
  local b = vim.api.nvim_create_buf(false, true)
  vim.bo[b].buftype = 'nofile'
  vim.bo[b].bufhidden = 'hide'
  vim.bo[b].swapfile = false
  vim.bo[b].modifiable = false
  vim.bo[b].filetype = FT
  vim.bo[b].buflisted = false
  vim.api.nvim_buf_set_name(b, ('mimir:%d'):format(index))

  vim.keymap.set('n', 'q', M.close, { buffer = b, silent = true, desc = 'Close mimir' })
  vim.keymap.set('n', '<leader>m', M.toggle, { buffer = b, silent = true, desc = 'Toggle mimir' })

  return b
end

local function ensure_bufs()
  for i = 1, 3 do
    if not (bufs[i] and vim.api.nvim_buf_is_valid(bufs[i])) then
      bufs[i] = make_buf(i)
    end
  end
  return bufs
end

---@param w integer
local function style_win(w)
  vim.wo[w].number = false
  vim.wo[w].relativenumber = false
  vim.wo[w].signcolumn = 'no'
  vim.wo[w].foldcolumn = '0'
  vim.wo[w].list = false
  vim.wo[w].wrap = false
  vim.wo[w].cursorline = false
  vim.wo[w].winfixwidth = true
  vim.wo[w].statusline = ' '
  vim.wo[w].winhighlight = 'Normal:MimirNormal,NormalNC:MimirNormal,WinSeparator:MimirNormal'
end

---@param opts? { focus?: boolean }
function M.open(opts)
  opts = opts or {}
  if M.is_open() then
    if opts.focus ~= false and vim.api.nvim_win_is_valid(wins[1]) then
      vim.api.nvim_set_current_win(wins[1])
    end
    return
  end

  local panels = ensure_bufs()
  local cur = vim.api.nvim_get_current_win()

  -- right column, then split it into three stacked panes
  vim.cmd 'botright vsplit'
  local top = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(top, panels[1])
  vim.api.nvim_win_set_width(top, config.width)
  style_win(top)

  vim.cmd 'split'
  local mid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(mid, panels[2])
  style_win(mid)

  vim.cmd 'split'
  local bot = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(bot, panels[3])
  style_win(bot)

  -- equalize the three stacked panes, keep column width fixed
  vim.cmd 'wincmd ='
  for _, w in ipairs { top, mid, bot } do
    if vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_set_width(w, config.width)
    end
  end

  wins = { top, mid, bot }

  if opts.focus == false then
    if vim.api.nvim_win_is_valid(cur) then
      vim.api.nvim_set_current_win(cur)
    end
  else
    vim.api.nvim_set_current_win(top)
  end
end

local closing = false

function M.close()
  if closing then
    return
  end
  closing = true
  -- close from bottom up so layout stays stable
  for i = #wins, 1, -1 do
    local w = wins[i]
    if w and vim.api.nvim_win_is_valid(w) then
      pcall(vim.api.nvim_win_close, w, true)
    end
  end
  wins = {}
  closing = false
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open { focus = true }
  end
end

-- if any mimir pane is closed manually, tear the whole column down
vim.api.nvim_create_autocmd('WinClosed', {
  group = vim.api.nvim_create_augroup('mimir-winclosed', { clear = true }),
  callback = function(args)
    if closing then
      return
    end
    local closed = tonumber(args.match)
    local hit = false
    for _, w in ipairs(wins) do
      if w == closed then
        hit = true
        break
      end
    end
    if not hit then
      return
    end
    vim.schedule(function()
      M.close()
    end)
  end,
})

return M
