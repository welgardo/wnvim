# wnvim

**First public release: v0.1.0.**

A beautiful, modular and easy-to-install [Neovim](https://neovim.io) configuration
distribution with 10 built-in themes (each with day/night variants), automatic
setup, and an installer designed to be safe and reversible: your existing
`~/.config/nvim` is moved to a timestamped backup — never deleted — and the
uninstaller restores it.

- **Backup-first installation** — in *standard* mode your current
  `~/.config/nvim` is moved (not copied-and-deleted) to
  `~/.local/share/wnvim/backups/nvim.<timestamp>/` before anything is written;
  if any step fails, the installer restores that backup and aborts. In *custom*
  mode your `~/.config/nvim` is not touched at all.
- **Runs alongside your existing setup** — install in *custom* mode and use the
  `wnvim` launcher; plain `nvim` stays untouched.
- **First-class theming** — a generated colorscheme (`wnvim`) with consistent
  colors across editor, statusline, picker and LSP UI. Switch instantly with
  `:WnvimTheme`, no restart required.
- **Batteries included** — completion, snippets, LSP (via Mason), Tree-sitter,
  file explorer, fuzzy finder, git signs, keymap hints and more.
- **Reproducible plugin set** — a committed `lazy-lock.json` pins every plugin
  to an exact revision.

## Requirements

| Requirement | Notes |
|---|---|
| Neovim >= 0.9 | checked by `install.sh` / `:WnvimDoctor` |
| Git | used by lazy.nvim and `wnvim --update` |
| Bash | installer, uninstaller and launcher |
| A Nerd Font *(recommended)* | icons in the file tree, statusline, completion menu |

## Installation

If this repository has been published on GitHub you can clone it from its
public URL; otherwise download/checkout the project from wherever you host it
and run the installer from the local clone:

```bash
git clone <your-wnvim-repository-url>   # e.g. once published: https://github.com/<owner>/wnvim.git
cd wnvim
./install.sh
```

The installer offers two modes:

- **Standard** — installs into `~/.config/nvim` (any existing config is backed
  up first under `~/.local/share/wnvim/backups/nvim.<timestamp>/`). After this,
  plain `nvim` *is* wnvim.
- **Custom** — keeps your `~/.config/nvim` intact and installs wnvim into a
  private directory (default: `~/.local/share/wnvim/config`). You then start it
  only through the `wnvim` command (installed to `~/.local/bin` by default).

Non-interactive usage:

```bash
./install.sh --standard              # always standard mode
./install.sh --custom                # custom mode into the default private dir
./install.sh --custom <dir>          # custom mode into <dir>
./install.sh --custom --appname      # custom mode via NVIM_APPNAME isolation
                                     # (config in $XDG_CONFIG_HOME/wnvim, with
                                     #  separate, persistent data/state dirs)
./install.sh --bin-dir /usr/local/bin  # where to place the `wnvim` launcher
./install.sh --no-plugins            # skip headless plugin bootstrap
./install.sh --help                  # full options
```

### Updating & uninstalling

```bash
wnvim --update      # git pull + plugin sync (or :WnvimUpdate inside wnvim)
wnvim --doctor      # environment health report (or :WnvimDoctor)
wnvim --uninstall   # remove wnvim and restore your previous config
./uninstall.sh      # same, from a clone of the repository
```

`uninstall.sh` never deletes anything it did not create, refuses to clobber a
config directory that exists again at restore time, and only removes the
`wnvim` launcher if its content still matches what was installed (SHA-256
verified). Flags: `--yes`, `--keep-backups`, `--dry-run`, `--bin-dir <dir>`.
Note: `wnvim --update` requires the *installed* config dir to be a git
checkout; when you installed by copying files (the default installer behavior),
re-run `install.sh` from a fresh clone instead. See
[`docs/RESTORE.md`](docs/RESTORE.md) for details.

## Themes

Themes are generated from declarative palettes in
[`lua/wnvim/themes/styles.lua`](lua/wnvim/themes/styles.lua) — adding a style
means adding one table entry, no extra plugins. Every style has **day** and
**night** variants; your selection is persisted between sessions
(`<data>/wnvim/state.json`; corrupt or missing state falls back to
Style 2 / Night).

| # | Style | # | Style |
|---|---|---|---|
| 1 | Minimal | 6 | Monochrome |
| 2 | Tokyo Neon *(default)* | 7 | Matrix |
| 3 | Cyberpunk | 8 | Pastel |
| 4 | Nord Ice | 9 | Material |
| 5 | Gruvbox Warm | 10 | Futuristic |

Commands:

| Command | Action |
|---|---|
| `:WnvimTheme` / `:WnvimThemeSelect` | open the theme picker |
| `:WnvimThemeDay` / `:WnvimThemeNight` | switch day/night variant |
| `:WnvimThemeNext` / `:WnvimThemePrev` | cycle styles |
| `:WnvimThemeSet {1-10} [day\|night]` | set style directly |

See [`docs/THEMES.md`](docs/THEMES.md) for details.

## Features

- **Plugin management** — [lazy.nvim](https://github.com/folke/lazy.nvim);
  plugins auto-install on first launch and are pinned via `lazy-lock.json`.
- **LSP** — nvim-lspconfig + Mason/mason-lspconfig for installing servers,
  none-ls for formatters/diagnostics.
- **Completion** — nvim-cmp with buffer/path/LSP sources, LuaSnip +
  friendly-snippets, lspkind icons.
- **Tree-sitter** — syntax highlighting plus textobjects.
- **UI** — lualine statusline, neo-tree file explorer, Telescope fuzzy finder
  (with optional fzf-native sorter), indent-blankline, gitsigns, which-key,
  web-devicons.

## Keybindings

Leader is `<Space>`. Press `<Space>` and wait to see everything live in
which-key. Highlights:

| Keys | Action |
|---|---|
| `<C-h/j/k/l>` | move between windows |
| `<leader>w` / `<leader>q` | save / quit window |
| `<S-h>` / `<S-l>` | previous / next buffer |
| `[d` / `]d` | previous / next diagnostic |
| `<leader>e` | file explorer toggle (see conflict note in docs/KEYMAPS.md) |
| `<leader>dl` | line/buffer diagnostics |

Full reference: [`docs/KEYMAPS.md`](docs/KEYMAPS.md).

## Project layout

```
init.lua                     # tiny entry point; loads lua/wnvim/* in order
lazy-lock.json               # pinned plugin revisions (used by lazy.nvim)
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
.github/        CI workflow (shellcheck, Lua checks, headless smoke test)
```

Load order in `init.lua`: globals → options → theme → lazy → autocmds/keymaps
→ commands → first-launch bootstrap.

## Release status & known gaps (v0.1.0)

This is the first public release. The automated checks below pass, but some
integration scenarios have not been exercised end-to-end yet:

- **Passing automatically:** shellcheck / `bash -n` on all scripts, Lua syntax
  checks, headless startup without errors/notifications, which-key health
  (startup mapping conflict fixed), all 20 theme variants generating >150
  highlight groups each, isolated install/uninstall/restore tests, CLI
  (`--help` / `--version` / `--doctor`).
- **`wnvim --update` / `:WnvimUpdate` remote path:** the installed config copy
  excludes `.git/`, so `wnvim --update` reports "not a git checkout" after a
  normal install and asks you to re-run `install.sh` from a clone. Live
  git-pull-based updating is therefore **not available in v0.1.0** (documented
  limitation, not a silent failure).
- **Interactive/visual quality** (colors actually looking right in your
  terminal, picker feel, LSP UX): NOT TESTABLE automatically — requires human
  terminal inspection.
- **`<leader>e` overlap:** bound by both core (diagnostics float) and neo-tree
  (explorer toggle); the effective binding depends on plugin load order — see
  the conflict note in [`docs/KEYMAPS.md`](docs/KEYMAPS.md). Tracked for a
  future release.
- **Screenshots/GIFs:** intentionally not part of v0.1.0.

## Troubleshooting

- Health check: `wnvim --doctor` or `:WnvimDoctor` inside Neovim.
- Restore a backed-up config: see [`docs/RESTORE.md`](docs/RESTORE.md).
- Common issues: [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

## License

Apache License 2.0 — see [LICENSE](LICENSE).
