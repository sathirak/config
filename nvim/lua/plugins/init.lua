-- plugins: auto-load category modules
-- dirs with init.lua load as a package; otherwise each *.lua is required
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'plugins')

---@param dir string
---@param prefix string
---@param modules string[]
local function collect(dir, prefix, modules)
  for name, ftype in vim.fs.dir(dir) do
    if ftype == 'directory' then
      local child = vim.fs.joinpath(dir, name)
      if vim.uv.fs_stat(vim.fs.joinpath(child, 'init.lua')) then
        table.insert(modules, prefix .. name)
      else
        collect(child, prefix .. name .. '.', modules)
      end
    elseif (ftype == 'file' or ftype == 'link') and name:match '%.lua$' and name ~= 'init.lua' then
      table.insert(modules, prefix .. (name:gsub('%.lua$', '')))
    end
  end
end

local modules = {}
collect(plugins_dir, '', modules)
table.sort(modules)

for _, module in ipairs(modules) do
  local ok, err = pcall(require, 'plugins.' .. module)
  if not ok then vim.notify(('Failed to load plugins.%s:\n%s'):format(module, err), vim.log.levels.ERROR) end
end
