# wnvim

A beautiful, modular and easy-to-install [Neovim](https://neovim.io) configuration
distribution with 10 built-in themes (each with day/night variants), automatic
setup, and a safe installer that never destroys your existing config.

- **Zero-clobber installation** — your current `~/.config/nvim` is moved to a
  timestamped backup, never deleted, and restored on uninstall.
- **Runs alongside your existing setup** — install in *custom* mode and use the
  `wnvim` launcher; plain `nvim` stays untouched.
- **First-class theming** — a generated colorscheme (`wnvim`) with consistent
  colors across editor, statusline, picker and LSP UI. Switch instantly with
  `:WnvimTheme`, no restart required.
- **Batteries included** — completion, snippets, LSP (via Mason), Tree-sitter,
  file explorer, fuzzy finder, git signs, keymap hints and more.

## Requirements

| Requirement | Notes |
|---|---|
| Neovim >= 0.9 | checked by `install.sh` / `:WnvimDoctor` |
| Git | used by lazy.nvim and `wnvim --update` |
| Bash | installer, uninstaller and launcher |
| A Nerd Font *(recommended)* | icons in the file tree, statusline, completion menu |

## Installation

```bash
git clone https://github.com/welgardo/wnvim.git
cd wnvim
./install.sh
```

The installer offers two modes:

- **Standard** — installs into `~/.config/nvim` (any existing config is backed
  up first under `~/.local/share/wnvim/backups/nvim.<timestamp>/`). After this,
  plain `nvim` *is* wnvim.
- **Custom** — keeps your `~/.config/nvim` intact and installs wnvim into a
  private directory. You then start it only through the `wnvim` command
  (installed to `~/.local/bin` by default).

Non-interactive usage:

```bash
./install.sh --standard              # always standard mode
./install.sh --custom <dir>          # always custom mode into <dir>
./install.sh --bin-dir /usr/local/bin  # where to place the `wnvim` launcher
./install.sh --no-plugins            # skip headless plugin bootstrap
./install.sh --help                  # full options
```

### Updating & uninstalling

```bash
wnvim --update      # git pull + plugin sync (or :WnvimUpdate inside wnvim)
wnvim --doctor      # environment health report (or :WnvimDoctor)
./uninstall.sh      # restores your previous config from the install manifest
```

`uninstall.sh` never deletes anything it did not create, refuses to clobber a
config directory that exists again at restore time, and only removes the
`wnvim` launcher if its content still matches what was installed (SHA-256
verified). Flags: `--yes`, `--keep-backups`, `--dry-run`, `--bin-dir <dir>`.

## Themes

Themes are generated from declarative palettes in
[`lua/wnvim/themes/styles.lua`](lua/wnvim/themes/styles.lua) — adding a style
means adding one table entry, no extra plugins. Every style has **day** and
**night** variants; your selection is persisted between sessions.

| # | Style | # | Style |
|---|---|---|---|
| 1 | Minimal | 6 | Monochrome |
| 2 | Tokyo Neon *(default)* | 7 | Matrix |
| 3 | Cyberpunk | 8 | Pastel |
| 4 | Nord Ice | 9 | Material |
| 5 | Gruv Warm | 10 | Futuristic |

Commands:

| Command | Action |
|---|---|
| `:WnvimTheme` / `:WnvimThemeSelect` | open the theme picker |
| `:WnvimThemeDay` / `:WnvimThemeNight` | switch day/night variant |
| `:WnvimThemeNext` / `:WnvimThemePrev` | cycle styles |
| `:WnvimThemeSet {n}` | set style number directly |

See [`docs/THEMES.md`](docs/THEMES.md) for details.

## Features

- **Plugin management** — [lazy.nvim](https://github.com/folke/lazy.nvim);
  plugins auto-install on first launch.
- **LSP** — nvim-lspconfig + Mason/mason-lspconfig for installing servers,
  none-ls for formatters/diagnostics.
- **Completion** — nvim-cmp with buffer/path/LSP sources, LuaSnip +
  friendly-snippets, lspkind icons.
- **Tree-sitter** — syntax highlighting plus textobjects.
- **UI** — lualine statusline, neo-tree file explorer, Telescope fuzzy finder
  (with fzf-native), indent-blankline, gitsigns, which-key, web-devicons.

## Keybindings

Leader is `<Space>`. Press `<Space>` and wait to see everything live in
which-key. Highlights:

| Keys | Action |
|---|---|
| `<C-h/j/k/l>` | move between windows |
| `<leader>w` / `<leader>q` | save / quit window |
| `<S-h>` / `<S-l>` | previous / next buffer |
| `[d` / `]d` | previous / next diagnostic |
| `<leader>e` | line diagnostics float |

Full reference: [`docs/KEYMAPS.md`](docs/KEYMAPS.md).

## Project layout

```
init.lua                     # tiny entry point; loads lua/wnvim/* in order
install.sh / uninstall.sh    # safe, reversible installer & uninstaller
scripts/wnvim.sh             # the `wnvim` launcher (custom mode)
lua/wnvim/
├── core/       globals, options, autocmds, keymaps
├── themes/     generated colorscheme + 10 style palettes
├── plugins/    lazy.nvim setup + per-area plugin specs
├── lsp/        server configuration
├── ui/         commands (:Wnvim*), theme picker, statusline
└── utils/      persistence & helpers
docs/           KEYMAPS, THEMES, TROUBLESHOOTING, RESTORE
```

Load order in `init.lua`: globals → options → theme → lazy → autocmds/keymaps
→ commands → first-launch bootstrap.

## Troubleshooting

- Health check: `wnvim --doctor` or `:WnvimDoctor` inside Neovim.
- Restore a backed-up config: see [`docs/RESTORE.md`](docs/RESTORE.md).
- Common issues: [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

## License

Apache License 2.0 — see [LICENSE](LICENSE).
