-- colorscheme: eternal (static, no lush)
vim.cmd 'highlight clear'
if vim.fn.exists 'syntax_on' == 1 then
  vim.cmd 'syntax reset'
end

vim.g.colors_name = 'eternal'
vim.o.background = 'dark'
vim.o.termguicolors = true

local c = {
  bg = '#08090c',
  bg_dark = '#030406',
  bg_dark_lighten4 = '#0a0d14',
  bg_dark_lighten2 = '#06090d',

  fg = '#cdd6f4',
  subtext1 = '#bac2de',
  subtext0 = '#a6adc8',
  overlay2 = '#9399b2',
  overlay1 = '#7f849c',
  overlay0 = '#6c7086',
  surface1 = '#45475a',

  rosewater = '#f5e0dc',
  flamingo = '#f2cdcd',
  pink = '#f5c2e7',
  mauve = '#cba6f7',
  red = '#f38ba8',
  maroon = '#eba0ac',
  peach = '#fab387',
  peach_dark = '#ae4707',
  peach_light = '#fef1e9',
  yellow = '#f9e2af',
  green = '#a6e3a1',
  teal = '#94e2d5',
  sky = '#89dceb',
  sapphire = '#74c7ec',
  blue = '#89b4fa',
  lavender = '#b4befe',
}

local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ui
hi('Normal', { bg = c.bg, fg = c.fg })
hi('NormalFloat', { bg = c.bg_dark, fg = c.fg })
hi('Comment', { fg = c.overlay0, italic = true })

hi('Visual', { bg = c.surface1, fg = c.fg })
hi('Search', { bg = c.peach_dark, fg = c.peach_light })
hi('IncSearch', { bg = c.peach, fg = c.bg_dark })
hi('CurSearch', { link = 'IncSearch' })

hi('Cursor', { bg = c.rosewater, fg = c.bg_dark })
hi('VisualCursor', { bg = c.fg, fg = c.bg_dark })

hi('LineNr', { fg = c.surface1 })
hi('CursorLineNr', { fg = c.mauve, bold = true })
hi('CursorLine', { bg = c.bg_dark_lighten4 })

hi('ColorColumn', { bg = c.bg_dark_lighten2 })
hi('SignColumn', { bg = c.bg })

hi('Pmenu', { bg = c.bg_dark, fg = c.fg })
hi('PmenuSel', { bg = c.surface1, fg = c.fg, bold = true })

-- syntax
hi('Identifier', { fg = c.fg })

hi('Type', { fg = c.yellow })
hi('Structure', { fg = c.yellow })
hi('Typedef', { fg = c.yellow })
hi('StorageClass', { fg = c.yellow })

hi('Keyword', { fg = c.mauve, italic = true })

hi('Statement', { fg = c.pink })
hi('Conditional', { fg = c.pink })
hi('Repeat', { fg = c.pink })
hi('Label', { fg = c.pink })

hi('Function', { fg = c.blue })

hi('Macro', { fg = c.maroon })
hi('PreProc', { fg = c.maroon })

hi('Constant', { fg = c.peach })
hi('Number', { fg = c.peach })
hi('Boolean', { fg = c.peach })
hi('Float', { fg = c.peach })

hi('String', { fg = c.green })
hi('Character', { fg = c.green })

hi('Operator', { fg = c.sky })
hi('Special', { fg = c.teal })
hi('SpecialChar', { fg = c.teal })

hi('Delimiter', { fg = c.overlay2 })

hi('Error', { fg = c.red, undercurl = true })
hi('Todo', { fg = c.bg, bg = c.yellow, bold = true })

-- lsp
hi('LspReferenceText', { bg = c.surface1 })
hi('LspReferenceRead', { link = 'LspReferenceText' })
hi('LspReferenceWrite', { link = 'LspReferenceText' })
hi('IlluminatedWordText', { link = 'LspReferenceText' })
hi('IlluminatedWordRead', { link = 'LspReferenceText' })
hi('IlluminatedWordWrite', { link = 'LspReferenceText' })

-- diagnostics
hi('DiagnosticError', { fg = c.red })
hi('DiagnosticWarn', { fg = c.yellow })
hi('DiagnosticInfo', { fg = c.sky })
hi('DiagnosticHint', { fg = c.teal })
hi('DiagnosticUnderlineError', { sp = c.red, undercurl = true })
hi('DiagnosticUnderlineWarn', { sp = c.yellow, undercurl = true })
hi('DiagnosticUnderlineInfo', { sp = c.sky, undercurl = true })
hi('DiagnosticUnderlineHint', { sp = c.teal, undercurl = true })

-- chrome
hi('FloatBorder', { bg = c.bg_dark, fg = c.surface1 })
hi('WinSeparator', { fg = c.surface1 })
hi('StatusLine', { bg = c.bg_dark, fg = c.fg })
hi('StatusLineNC', { bg = c.bg_dark, fg = c.overlay0 })

-- neo-tree
hi('Directory', { fg = c.peach })
hi('NeoTreeDirectoryIcon', { fg = c.peach })
hi('NeoTreeDirectoryName', { fg = c.flamingo })
hi('NeoTreeRootName', { fg = c.yellow, bold = true })
hi('NeoTreeExpander', { fg = c.flamingo })

-- treesitter
hi('@variable', { link = 'Identifier' })
hi('@type', { link = 'Type' })
hi('@keyword', { link = 'Keyword' })
hi('@keyword.function', { link = 'Keyword' })
hi('@function', { link = 'Function' })
hi('@function.macro', { link = 'Macro' })
hi('@constant', { link = 'Constant' })
hi('@string', { link = 'String' })
hi('@number', { link = 'Number' })
hi('@boolean', { link = 'Boolean' })
hi('@operator', { link = 'Operator' })
hi('@punctuation.delimiter', { link = 'Delimiter' })
hi('@punctuation.bracket', { link = 'Delimiter' })
hi('@comment', { link = 'Comment' })
