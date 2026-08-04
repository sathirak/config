# Neovim

Lightning fast Lua-based Neovim configuration built around Neovim's built-in package manager, `vim.pack`, and a small set of opinionated modules. The config is split into a core boot path, shared editor settings, and plugin modules grouped by feature area.

## Architecture

Startup is intentionally simple:

1. `init.lua` enables the Lua loader cache.
2. Core modules are loaded in a fixed order:
   - `lua/config/options.lua`
   - `lua/config/keymaps.lua`
   - `lua/config/autocmds.lua`
   - `lua/config/pack.lua`
3. `lua/plugins/init.lua` recursively discovers and requires every plugin module under `lua/plugins/`.

The plugin loader is directory-driven. Any `*.lua` file under `lua/plugins/` is loaded, and subdirectories with their own `init.lua` are treated as grouped modules. This keeps the config modular without needing a separate plugin manager manifest.

## Layout

```text
nvim/
  init.lua
  colors/
    eternal.lua
  lua/
    config/
      autocmds.lua
      keymaps.lua
      options.lua
      pack.lua
    plugins/
      init.lua
      completion/
      editor/
      lsp/
      navigation/
      ui/
```

## Core Editor Behavior

The core config sets the global editing defaults:

- `<Space>` is the leader key.
- Relative and absolute line numbers are enabled.
- Clipboard is wired to `unnamedplus`.
- Search, split, scroll, and diagnostic display settings are tuned for daily use.
- Yank highlighting is handled by an autocmd.

Global keymaps are minimal and focused on common editing actions such as clearing search highlights, saving, moving between windows, and toggling diagnostics.

## Plugin Architecture

Plugins are grouped by purpose:

- `completion/` for completion and snippets.
- `editor/` for formatting, treesitter, git helpers, and motion tools.
- `lsp/` for language-server bootstrap and per-language server/tool declarations.
- `navigation/` for Telescope, Neo-tree, and symbol navigation UI.
- `ui/` for statusline, dashboard, session handling, notifications, and theme setup.

The config uses `vim.pack.add` directly instead of lazy.nvim. Package versions are tracked in `nvim-pack-lock.json`.

Keybindings are centralized in `lua/config/keymaps.lua`; plugin files stay setup-only.

## What It Uses

### Completion

- `blink.cmp` for completion.
- `LuaSnip` for snippets.

### Syntax and Parsing

- `nvim-treesitter` with parser install-on-demand behavior.
- Tree-sitter language registration for `bzl` via `starlark`.

### LSP

- `nvim-lspconfig`

Language modules currently cover:

- `lua_ls`
- `nixd`
- `rust_analyzer`
- `ts_ls`
- `starpls`

All language servers are managed by Nix-darwin in this setup. Neovim only configures and enables them through `nvim-lspconfig`; it does not install LSP servers itself.

### Formatting

- `conform.nvim`
- `buildifier` for `bzl`

### Navigation and Search

- `telescope.nvim`
- `telescope-fzf-native.nvim` when `make` is available
- `telescope-ui-select.nvim`
- `neo-tree.nvim`
- `flash.nvim`
- `nvim-navbuddy`
- `nvim-navic`

### Git and Project Signals

- `gitsigns.nvim`
- `diffview.nvim`
- `git-blame.nvim`
- `guess-indent.nvim`

### UI

- `fidget.nvim` for LSP progress
- `mini.nvim` for `mini.surround`
- `todo-comments.nvim`
- custom `statusline.lua`
- `dashboard.lua` startup screen
- `colors/eternal.lua` custom colorscheme

## Tools and Keybindings

### Tooling

| Tool | Repo | Notes |
| --- | --- | --- |
| `blink.cmp` | [saghen/blink.cmp](https://github.com/saghen/blink.cmp) | Completion with `super-tab` behavior |
| `LuaSnip` | [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet expansion |
| `nvim-lspconfig` | [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP wiring only; binaries come from Nix-darwin |
| `nvim-treesitter` | [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Parser install + attach |
| `conform.nvim` | [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | Formatting |
| `telescope.nvim` | [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| `telescope-fzf-native.nvim` | [nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | Optional native sorter, needs `make` |
| `neo-tree.nvim` | [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer |
| `flash.nvim` | [folke/flash.nvim](https://github.com/folke/flash.nvim) | Jump labels and Treesitter motions |
| `nvim-navbuddy` | [SmiteshP/nvim-navbuddy](https://github.com/SmiteshP/nvim-navbuddy) | Symbol outline |
| `nvim-navic` | [SmiteshP/nvim-navic](https://github.com/SmiteshP/nvim-navic) | Symbol breadcrumbs for the statusline |
| `gitsigns.nvim` | [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git signs in the gutter |
| `diffview.nvim` | [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim) | Diff UI |
| `git-blame.nvim` | [f-person/git-blame.nvim](https://github.com/f-person/git-blame.nvim) | Inline blame text |
| `guess-indent.nvim` | [NMAC427/guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim) | Detect indentation |
| `fidget.nvim` | [j-hui/fidget.nvim](https://github.com/j-hui/fidget.nvim) | LSP progress |
| `mini.nvim` | [nvim-mini/mini.nvim](https://github.com/nvim-mini/mini.nvim) | `mini.surround` |
| `todo-comments.nvim` | [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight TODO/FIXME style comments |

### Keybindings

| Key | What it does |
| --- | --- |
| `<Esc>` | Clear search highlight |
| `<C-h> <C-j> <C-k> <C-l>` | Move between windows |
| `<C-s>` in normal/insert/visual mode | Save all buffers |
| `J` | Open diagnostics for the current line |
| `<leader>q` | Put diagnostics into the location list |
| `<leader>f` | Format the current buffer |
| `s`, `S`, `r`, `R`, `<C-s>` in command-line mode | Flash jump, Treesitter jump, remote flash, Treesitter search, toggle flash search |
| `\` | Reveal the current file in Neo-tree |
| `<leader>n` | Open Navbuddy |
| `<leader>sa`, `<leader>r`, `<leader>sf`, `<leader>sg`, `<leader>sw`, `<leader>sb`, `<leader><leader>`, `<leader>s.`, `<leader>/`, `<leader>s/`, `<leader>sn`, `<leader>sh`, `<leader>sk`, `<leader>sc`, `<leader>ss`, `<leader>sS`, `<leader>sr`, `<leader>sd` | Telescope pickers for files, grep, buffers, config, help, keymaps, commands, symbols, references, and diagnostics |
| `<leader>qs`, `<leader>qd` | Restore or delete the current directory session |
| `s` in the dashboard buffer | Restore the current directory session |
| `gd`, `gr`, `gI`, `gy`, `gD`, `K`, `gK`, `<C-k>` | LSP definition, references, implementation, type definition, declaration, hover, signature help |
| `<leader>cl`, `<leader>ca`, `<leader>cA`, `<leader>co`, `<leader>cc`, `<leader>cC`, `<leader>cr`, `<leader>cR`, `<leader>uh` | LSP info, code actions, source actions, organize imports, codelens, rename, rename file, toggle inlay hints |
| `]d`, `[d`, `]e`, `[e`, `]w`, `[w` | Jump diagnostics by severity |

### External Dependencies

This config is designed to work with the surrounding Nix-darwin setup. The system profile owns the LSP and formatter binaries, including `nixd`, `nixfmt`, `lua-language-server`, `rust-analyzer`, `basedpyright`, `ruff`, `typescript-language-server`, `bash-language-server`, `fish-lsp`, `shellcheck`, `shfmt`, `stylua`, `prettierd`, `buildifier`, and `starpls`.

JavaScript and TypeScript support also needs a Node runtime, which is provided by Nix-darwin alongside `typescript-language-server`.

Other supporting tools used by plugins include `ripgrep`, `fd`, `fzf`, `git`, `tree-sitter`, and `make` for the optional Telescope FZF native extension.

Nix-darwin is the intended owner for these system-level binaries; Neovim consumes them through the LSP and formatter modules.

## Sessions

Sessions are saved per working directory under Neovim's state directory. The dashboard shows a session hint and lets you restore the current directory's session with `s`.

## Theme

The active colorscheme is `eternal`, a custom dark theme defined in `colors/eternal.lua`. UI components such as the statusline and Neo-tree are styled to match it.

## Notes

- `nvim-pack-lock.json` records the plugin revisions used by `vim.pack`.
- `lua/plugins/init.lua` is the main plugin loader; individual feature files are intentionally small and composable.
- `lua/config/pack.lua` adds a few post-install hooks for package builds such as Treesitter, Telescope's FZF extension, and LuaSnip's JS regexp support.
