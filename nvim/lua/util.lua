-- util: shared helpers
local M = {}

---@param repo string owner/repo
---@return string
function M.gh(repo) return 'https://github.com/' .. repo end

return M
