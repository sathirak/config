-- ~/.config/nvim/lua/lush_theme/sandbox.lua

local lush = require("lush")
local hsl = lush.hsl

-- =============================================================================
-- The Catppuccin Mocha Palette (Mapped for Rust Ergonomics + Pitch Black BG)
-- =============================================================================
local c = {
  -- User's ultra-dark backgrounds
  bg = hsl("#08090c"),
  bg_dark = hsl("#030406"),

  -- Catppuccin Mocha UI & Text
  fg = hsl("#cdd6f4"), -- Text
  subtext1 = hsl("#bac2de"),
  subtext0 = hsl("#a6adc8"),
  overlay2 = hsl("#9399b2"), -- Used for dimming delimiters/brackets
  overlay1 = hsl("#7f849c"),
  overlay0 = hsl("#6c7086"), -- Comments (Soft enough to ignore, crisp enough to read)

  -- UI Highlights
  surface1 = hsl("#45475a"), -- Good for visual selections on black

  -- Catppuccin Mocha Colors
  rosewater = hsl("#f5e0dc"),
  flamingo = hsl("#f2cdcd"),
  pink = hsl("#f5c2e7"),
  mauve = hsl("#cba6f7"), -- (Purple) Engine keywords
  red = hsl("#f38ba8"),
  maroon = hsl("#eba0ac"),
  peach = hsl("#fab387"), -- (Orange)
  yellow = hsl("#f9e2af"),
  green = hsl("#a6e3a1"),
  teal = hsl("#94e2d5"),
  sky = hsl("#89dceb"), -- (Light Cyan)
  sapphire = hsl("#74c7ec"),
  blue = hsl("#89b4fa"),
  lavender = hsl("#b4befe"),
}

local spec = lush(function()
  return {
    -- =========================================================================
    -- 1. Core Editor Base UI
    -- =========================================================================
    Normal({ bg = c.bg, fg = c.fg }),
    NormalFloat({ bg = c.bg_dark, fg = c.fg }),
    Comment({ fg = c.overlay0, gui = "italic" }),

    -- Text Selection & LSP References (Visible but not blinding)
    Visual({ bg = c.surface1, fg = c.fg }),
    Search({ bg = c.peach.darken(40), fg = c.peach.lighten(20) }),
    IncSearch({ bg = c.peach, fg = c.bg_dark }),
    CurSearch({ IncSearch }),

    Cursor({ bg = c.rosewater, fg = c.bg_dark }),
    VisualCursor({ bg = c.fg, fg = c.bg_dark }),

    LineNr({ fg = c.surface1 }),
    CursorLineNr({ fg = c.mauve, gui = "bold" }),
    CursorLine({ bg = c.bg_dark.lighten(4) }),

    ColorColumn({ bg = c.bg_dark.lighten(2) }),
    SignColumn({ bg = c.bg }),

    Pmenu({ bg = c.bg_dark, fg = c.fg }),
    PmenuSel({ bg = c.surface1, fg = c.fg, gui = "bold" }),

    -- =========================================================================
    -- 2. Rust Ergonomics Syntax Mapping
    -- =========================================================================

    -- Variables and Standard Text
    Identifier({ fg = c.fg }),

    -- Types & Traits (Yellow makes Enums, Structs, and Traits pop as domain models)
    Type({ fg = c.yellow }),
    Structure({ fg = c.yellow }),
    Typedef({ fg = c.yellow }),
    StorageClass({ fg = c.yellow }),

    -- Engine Declarations (Mauve for let, mut, fn, pub, impl)
    Keyword({ fg = c.mauve, gui = "italic" }),

    -- Control Flow (Pink specifically for match, if, return, break - separates from 'let')
    Statement({ fg = c.pink }),
    Conditional({ fg = c.pink }),
    Repeat({ fg = c.pink }),
    Label({ fg = c.pink }),

    -- Functions & Methods (Blue keeps execution logic calm and readable)
    Function({ fg = c.blue }),

    -- Macros (Maroon differentiates println! and vec! from standard functions)
    -- In Rust, macros are distinct. You don't want them pure red (looks like errors)
    -- or blue (looks like standard fns).
    Macro({ fg = c.maroon }),
    PreProc({ fg = c.maroon }), -- #[derive(...)], #[inline] attributes

    -- Constants, Numbers & Booleans (Peach creates a distinct scalar group)
    Constant({ fg = c.peach }),
    Number({ fg = c.peach }),
    Boolean({ fg = c.peach }),
    Float({ fg = c.peach }),

    -- Strings and Characters (Standard Green, safe for eyes)
    String({ fg = c.green }),
    Character({ fg = c.green }),

    -- Operators & Lifetimes (Sky & Teal)
    -- In Rust, `->`, `=>`, `?`, and `&` dictate the flow of data.
    Operator({ fg = c.sky }),
    Special({ fg = c.teal }), -- Used for Lifetimes ('a)
    SpecialChar({ fg = c.teal }),

    -- Delimiters (Massive eye-strain saver)
    -- Dimming brackets, braces, and colons so the code logic stands out, not the structure.
    Delimiter({ fg = c.overlay2 }),

    -- Diagnostics
    Error({ fg = c.red, gui = "undercurl" }),
    Todo({ fg = c.bg, bg = c.yellow, gui = "bold" }),

    -- =========================================================================
    -- 3. LSP Hover & Word References
    -- =========================================================================
    LspReferenceText({ bg = c.surface1 }),
    LspReferenceRead({ LspReferenceText }),
    LspReferenceWrite({ LspReferenceText }),
    IlluminatedWordText({ LspReferenceText }),
    IlluminatedWordRead({ LspReferenceText }),
    IlluminatedWordWrite({ LspReferenceText }),
  }
end)

return spec
