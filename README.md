# wnvim

> Automatically configure Neovim with a ready-to-use setup.

wnvim takes a fresh Neovim installation and automatically applies a curated
configuration — plugins, keybindings, LSP, completion and visual settings —
with a safe, reversible installer. Your existing config is backed up, never
deleted.

## Features

- Automatic Neovim configuration (one installer run)
- Ready-to-use plugins: lazy.nvim, LSP + Mason, nvim-cmp, LuaSnip,
  Tree-sitter, Telescope, neo-tree, gitsigns, lualine, which-key
- 10 visual styles, each with light (day) and dark (night) variants
- Instant theme switching (`:WnvimTheme`), persisted between sessions
- Sensible defaults; everything lives in plain Lua so it is easy to customize
- Reproducible plugin set via a committed `lazy-lock.json`
- Two install modes: replace `~/.config/nvim`, or coexist via a `wnvim` launcher
- Easy uninstall that restores your previous configuration
- Open source (Apache 2.0)

## Preview

Screenshots are not part of this release yet.

<!-- TODO: add screenshots/GIFs of the theme picker and editor styles -->

## Installation

```bash
git clone https://github.com/welgardo/wnvim.git
cd wnvim
./install.sh
```

The installer then:

1. Checks required dependencies (Git, tar) and detects Neovim (>= 0.9).
2. Asks you to pick an install mode:
   - **Standard** — installs into `~/.config/nvim`. Any existing config is
     *moved* to `~/.local/share/wnvim/backups/nvim.<timestamp>/` first; after
     this, plain `nvim` is wnvim.
   - **Custom** — leaves your `~/.config/nvim` untouched and installs wnvim
     into a private directory (default `~/.local/share/wnvim/config`). You
     start it with the `wnvim` command (installed to `~/.local/bin`).
3. Copies the configuration and bootstraps plugins headlessly.
4. Verifies the setup and prints what was installed and where.

If any step fails, the installer restores your backup and aborts.

Non-interactive flags: `--standard`, `--custom [dir]`, `--appname`,
`--bin-dir <dir>`, `--no-plugins`, `--help`.

## Usage

After a **standard** install:

```bash
nvim
```

After a **custom** install:

```bash
wnvim
```

Plugins finish installing on first launch. To change the visual style, run
`:WnvimTheme` inside Neovim and pick a style and day/night variant — no
restart needed. Your choice is persisted across sessions.

## Configuration

wnvim is installed as a normal Neovim config, so you can edit it directly:

| Mode | Location |
| --- | --- |
| Standard | `~/.config/nvim` |
| Custom | `~/.local/share/wnvim/config` (or the directory you chose) |

Key files: options and keymaps in `lua/wnvim/core/`, plugins in
`lua/wnvim/plugins/`, theme palettes in `lua/wnvim/themes/styles.lua`.
Health check: `wnvim --doctor` or `:WnvimDoctor`.

## Themes

Every style has both a light (day) and dark (night) variant. Default:
Tokyo Neon / Night.

| Style | Light | Dark |
| --- | :-: | :-: |
| Minimal | ✓ | ✓ |
| Tokyo Neon *(default)* | ✓ | ✓ |
| Cyberpunk | ✓ | ✓ |
| Nord Ice | ✓ | ✓ |
| Gruvbox Warm | ✓ | ✓ |
| Monochrome | ✓ | ✓ |
| Matrix | ✓ | ✓ |
| Pastel | ✓ | ✓ |
| Material | ✓ | ✓ |
| Futuristic | ✓ | ✓ |

Commands: `:WnvimTheme` (picker), `:WnvimThemeDay` / `:WnvimThemeNight`,
`:WnvimThemeNext` / `:WnvimThemePrev`, `:WnvimThemeSet {1-10} [day|night]`.
Details: [`docs/THEMES.md`](docs/THEMES.md).

## Uninstall

```bash
wnvim --uninstall
```

Or from a clone of the repository: `./uninstall.sh`. The uninstaller removes
only what the installer created and restores your previously backed-up
`~/.config/nvim`. Flags: `--yes`, `--keep-backups`, `--dry-run`. Details:
[`docs/RESTORE.md`](docs/RESTORE.md).

## Requirements

| Requirement | Notes |
| --- | --- |
| Neovim >= 0.9 | checked by `install.sh` |
| Git | plugin management (lazy.nvim) |
| Bash | installer, uninstaller, launcher |
| Nerd Font | recommended — icons in tree, statusline, completion |

Optional (features degrade gracefully without them): `rg`, `fd`, `fzf`,
`node`/`npm`.

## Project structure

```
init.lua                  # entry point
install.sh / uninstall.sh # safe, reversible installer/uninstaller
scripts/wnvim.sh          # the `wnvim` launcher (custom mode)
lazy-lock.json            # pinned plugin revisions
lua/wnvim/
├── core/       options, keymaps, autocmds
├── themes/     generated colorscheme + 10 style palettes
├── plugins/    lazy.nvim setup and plugin specs
├── lsp/        server configuration
├── ui/         commands, theme picker, statusline
└── utils/      persistence & helpers
docs/           KEYMAPS, THEMES, TROUBLESHOOTING, RESTORE
```

## Contributing

1. Fork the repository.
2. Create a branch for your change.
3. Make your changes (CI runs shellcheck, Lua syntax checks, and a headless
   startup smoke test).
4. Open a pull request.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
