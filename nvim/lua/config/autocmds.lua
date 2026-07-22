-- autocmds: editor behavior
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- autosave: debounce writes; skip special/unwritable buffers
do
  local delay_ms = 1000
  ---@type table<integer, uv.uv_timer_t>
  local timers = {}

  ---@param buf integer
  local function clear_timer(buf)
    local t = timers[buf]
    if not t then
      return
    end
    timers[buf] = nil
    if not t:is_closing() then
      t:stop()
      t:close()
    end
  end

  ---@param buf integer
  local function should_save(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
      return false
    end
    if not vim.api.nvim_buf_is_loaded(buf) then
      return false
    end

    local bo = vim.bo[buf]
    if bo.buftype ~= '' or bo.readonly or not bo.modifiable or not bo.modified then
      return false
    end
    if bo.filetype == 'neo-tree' or bo.filetype == 'dashboard' then
      return false
    end

    local name = vim.api.nvim_buf_get_name(buf)
    if name == '' or vim.startswith(name, 'oil:') then
      return false
    end

    -- skip buffers whose path is not writable / not a normal file yet on a bad fs
    if vim.fn.filewritable(name) == 0 and vim.uv.fs_stat(name) then
      return false
    end

    return true
  end

  ---@param buf integer
  local function save(buf)
    if not should_save(buf) then
      return
    end

    -- noautocmd: avoid formatters / heavy BufWrite hooks; still persists the file
    pcall(vim.api.nvim_buf_call, buf, function()
      vim.cmd 'silent! noautocmd update'
    end)
  end

  ---@param buf integer
  local function save_soon(buf)
    clear_timer(buf)
    if not should_save(buf) then
      return
    end

    local t = assert(vim.uv.new_timer())
    timers[buf] = t
    t:start(
      delay_ms,
      0,
      vim.schedule_wrap(function()
        clear_timer(buf)
        save(buf)
      end)
    )
  end

  ---@param buf integer
  local function save_now(buf)
    clear_timer(buf)
    save(buf)
  end

  local function save_all()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      save_now(buf)
    end
  end

  local group = vim.api.nvim_create_augroup('autosave', { clear = true })

  -- typing: coalesce writes so we never hit disk per keystroke
  vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged', 'TextChangedI' }, {
    group = group,
    callback = function(args)
      save_soon(args.buf)
    end,
  })

  -- leaving a buffer/window: flush that buffer
  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
    group = group,
    callback = function(args)
      save_now(args.buf)
    end,
  })

  -- leaving Neovim / OS focus: flush every modified file
  vim.api.nvim_create_autocmd({ 'FocusLost', 'VimLeavePre' }, {
    group = group,
    callback = save_all,
  })

  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufUnload' }, {
    group = group,
    callback = function(args)
      clear_timer(args.buf)
    end,
  })
end
