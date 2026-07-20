-- Parsers and queries installed under stdpath("data")/site must be on 'runtimepath'
-- (see :checkhealth nvim-treesitter when using TSInstall into ~/.local/share/nvim/site).
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
