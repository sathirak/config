-- navbuddy: LSP symbol outline
local gh = require('util').gh
local keymaps = require 'config.keymaps'

vim.pack.add {
  gh 'SmiteshP/nvim-navbuddy',
  gh 'SmiteshP/nvim-navic',
  gh 'MunifTanjim/nui.nvim',
}

local S = '\u{f486} ' -- Structure (File, Module, Class, Interface, Struct, Object)
local F = '\u{f49d} ' -- Function (Function, Method, Constructor, Event, Macro)
local V = '  ' -- Variable (Variable, Field, Property, Constant, Key)
local T = '\u{f488} ' -- Type (Enum, EnumMember, TypeParameter)
local L = '\u{f424} ' -- Value (String, Number, Boolean, Array, Null, Operator)

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
      leaf_selected = ' \u{f401} ',
      branch = ' \u{f470} ',
    },
  },
  icons = {
    [1]   = S, -- File
    [2]   = S, -- Module
    [3]   = S, -- Namespace
    [4]   = S, -- Package
    [5]   = S, -- Class
    [6]   = F, -- Method
    [7]   = V, -- Property
    [8]   = V, -- Field
    [9]   = F, -- Constructor
    [10]  = T, -- Enum
    [11]  = S, -- Interface
    [12]  = F, -- Function
    [13]  = V, -- Variable
    [14]  = V, -- Constant
    [15]  = L, -- String
    [16]  = L, -- Number
    [17]  = L, -- Boolean
    [18]  = L, -- Array
    [19]  = S, -- Object
    [20]  = V, -- Key
    [21]  = L, -- Null
    [22]  = T, -- EnumMember
    [23]  = S, -- Struct
    [24]  = F, -- Event
    [25]  = L, -- Operator
    [26]  = T, -- TypeParameter
    [255] = F, -- Macro
  },
  mappings = keymaps.navbuddy_mappings(),
  use_default_mappings = true,
}
