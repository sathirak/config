return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local extra = {
        "css",
        "latex",
        "norg",
        "scss",
        "svelte",
        "typst",
        "vue",
      }
      local cur = opts.ensure_installed
      if cur == nil then
        opts.ensure_installed = extra
      elseif type(cur) == "table" then
        vim.list_extend(cur, extra)
      end
    end,
  },
}
