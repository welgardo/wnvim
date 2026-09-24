# wnvim Keymaps

Leader is `<Space>` (set before any plugin loads). Which-key shows all of
these live: press `<Space>` and wait, or press an incomplete prefix.

> Note: which-key only labels keymaps that exist when it loads
> (`VeryLazy`). Core maps defined at startup — including `[d`/`]d`,
> `<leader>w`, `<leader>q`, `<S-h>`/`<S-l>` — carry their descriptions and
> appear in the which-key popup; the group headers for `[`, `]`, `<leader>f`,
> etc. are registered by the plugin specs.

## Core (always available, no plugins required)

Defined in `lua/wnvim/core/keymaps.lua`.

| Keys | Mode | Action |
|---|---|---|
| `<Esc>` | n | Clear search highlight |
| `<Esc><Esc>` | t | Terminal → normal mode |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | n | Window left/down/up/right |
| `<leader>w` | n | Save file (`:write`) |
| `<leader>q` | n | Quit window |
| `<leader>-` / <code>&#124;</code> | n | Split horizontal / vertical |
| `<S-h>` / `<S-l>` | n | Previous / next buffer |
| `[d` / `]d` | n | Prev / next diagnostic (jump list) |
| `<leader>e` | n | Line diagnostics float ⚠ see conflict note |
| `<leader>dl` | n | Buffer diagnostics → location list |
| `<leader>a` | n | Select all |
| `<leader>R` | n | Reload config (`source $MYVIMRC`) |
| `J` / `K` | v | Move selection down/up (re-indents) |
| `<C-d>` / `<C-u>` | n | Half-page scroll, cursor centered |
| `n` / `N` | n | Search step, cursor centered |

### Known overlap (documented behavior)

`<leader>e` is bound twice by design intent but resolves to **one** winner:
the core binding (diagnostics float) is set at startup; neo-tree's lazy
binding replaces it the first time neo-tree loads. Effectively `<leader>e`
is the **file explorer toggle**, and line diagnostics are available via
`<leader>dl` and `[d`/`]d`. This is tracked for a future release; both
bindings exist in the source today.

## File explorer — neo-tree

| Keys | Action |
|---|---|
| `<leader>e` | Toggle explorer |
| `<leader>o` | Focus explorer |
| `h` / `l` (in tree) | Close / open node |

## Telescope (find)

| Keys | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (needs `rg`) |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fk` | Keymaps |
| `<leader>fc` | Commands |
| `<leader>fr` | Recent files |
| `<leader>/` | Fuzzy search in current buffer |
| `<leader>th` | **Theme selector** (two-step picker) |

## Git (gitsigns, buffer-local in git repos)

| Keys | Action |
|---|---|
| `]c` / `[c` | Next / previous hunk |
| `<leader>gs` / `<leader>gr` | Stage / reset hunk |
| `<leader>gS` | Stage whole buffer |
| `<leader>gp` / `<leader>gn` | Prev / next hunk (aliases) |
| `<leader>gh` | Preview hunk |
| `<leader>gB` | Blame line |
| `<leader>gd` | Diff against index |
| `<leader>gq` | All hunks → quickfix |

## LSP (buffer-local once a server attaches)

| Keys | Action |
|---|---|
| `gd` / `gD` / `gi` / `gr` | Definition / declaration / implementation / type definition |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>lf` | Format buffer (via LSP / none-ls) |
| `<leader>ds` | Document diagnostics (telescope, else loclist) |
| `<leader>ws` | Workspace symbols (telescope) |
| `<C-h>` (insert) | Signature help |

## Completion (nvim-cmp, insert mode)

| Keys | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | Next / prev item (or snippet jump; falls back to native completion when menu closed) |
| `<CR>` | Confirm selected item (never auto-selects) |
| `<C-Space>` | Trigger completion manually |
| `<C-e>` | Abort / dismiss menu |
| `<C-b>` / `<C-f>` | Scroll doc window up/down |

## Buffers

| Keys | Action |
|---|---|
| `<leader>bd` | Delete buffer without closing window (mini.bufremove) |

## Treesitter

| Keys | Action |
|---|---|
| `<leader>tS` | Treesitter symbols (telescope) |
| `<leader>tI` | `:TSInstall ` (type parser name) |
| `<leader>tU` | `:TSUpdate` |

## Which-key groups

`<leader>f` find · `<leader>b` buffer · `<leader>g` git · `<leader>l` lsp ·
`<leader>d` diagnostics · `<leader>t` theme/test · `<leader>c` code/close ·
`<leader>s` split/session · `<leader>q` quit · `[`/`]` prev/next
