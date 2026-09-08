-- navbuddy: LSP symbol outline
local gh = require('util').gh
local keymaps = require 'config.keymaps'

vim.pack.add {
  gh 'SmiteshP/nvim-navbuddy',
  gh 'SmiteshP/nvim-navic',
  gh 'MunifTanjim/nui.nvim',
}

local S = ' ' -- Structure (File, Module, Namespace, Package, Class, Interface, Object, Struct)
local F = ' ' -- Function (Method, Function, Constructor, Event, Macro)
local V = ' ' -- Variable (Property, Field, Variable, Constant, Key)
local T = ' ' -- Type (Enum, EnumMember, TypeParameter)
local L = '  ' -- Value (String, Number, Boolean, Array, Null, Operator)

-- Apply colorscheme colors to navbuddy/navic symbol groups
local function apply_navic_highlights()
  local category_hl = {
    -- S: Structure
    NavicIconsFile          = 'Type',
    NavicIconsModule        = 'Type',
    NavicIconsNamespace     = 'Type',
    NavicIconsPackage       = 'Type',
    NavicIconsClass         = 'Type',
    NavicIconsInterface     = 'Type',
    NavicIconsObject        = 'Type',
    NavicIconsStruct        = 'Type',

    -- F: Function
    NavicIconsFunction      = 'Function',
    NavicIconsMethod        = 'Function',
    NavicIconsConstructor   = 'Function',
    NavicIconsEvent         = 'Function',
    NavicIconsMacro         = 'Function',

    -- V: Variable
    NavicIconsVariable      = 'Identifier',
    NavicIconsProperty      = 'Identifier',
    NavicIconsField         = 'Identifier',
    NavicIconsConstant      = 'Identifier',
    NavicIconsKey           = 'Identifier',

    -- T: Type
    NavicIconsEnum          = 'TypeDef',
    NavicIconsEnumMember    = 'TypeDef',
    NavicIconsTypeParameter = 'TypeDef',

    -- L: Value / Literal
    NavicIconsString        = 'String',
    NavicIconsNumber        = 'String',
    NavicIconsBoolean       = 'String',
    NavicIconsArray         = 'String',
    NavicIconsNull          = 'String',
    NavicIconsOperator      = 'String',
  }

  for group, link in pairs(category_hl) do
    vim.api.nvim_set_hl(0, group, { link = link, default = true })
  end
end

apply_navic_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('navbuddy-colors', { clear = true }),
  callback = apply_navic_highlights,
})

require('nvim-navbuddy').setup {
  lsp = { auto_attach = true },
  window = {
    border = 'rounded',
    sections = {
      left = { size = '20%' },
      mid = { size = '40%' },
      right = { preview = 'leaf' },
    },
  },
  node_markers = {
    enabled = true,
    icons = {
      leaf = '  ',
      leaf_selected = '  ',
      branch = ' 󰄾 ',
    },
  },
  icons = {
    File          = S,
    Module        = S,
    Namespace     = S,
    Package       = S,
    Class         = S,
    Method        = F,
    Property      = V,
    Field         = V,
    Constructor   = F,
    Enum          = T,
    Interface     = S,
    Function      = F,
    Variable      = V,
    Constant      = V,
    String        = L,
    Number        = L,
    Boolean       = L,
    Array         = L,
    Object        = S,
    Key           = V,
    Null          = L,
    EnumMember    = T,
    Struct        = S,
    Event         = F,
    Operator      = L,
    TypeParameter = T,
    Macro         = F,
  },
  mappings = keymaps.navbuddy_mappings(),
  use_default_mappings = true,
}
