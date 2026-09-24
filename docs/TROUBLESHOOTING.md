# wnvim Troubleshooting

## First: run the doctor

```sh
wnvim --doctor          # from your shell
```
or
```vim
:WnvimDoctor            ; inside Neovim (opens a report in a right split)
```

The doctor prints Neovim version, active theme, state/config/data paths, and
checks for `git`, `curl`, `tar`, `rg`, `fd`, `fzf`, `node`, `npm`, `python3`,
plus whether lazy.nvim / mason / treesitter are loaded.

## Installation problems

**"Neovim ('nvim') was not found on PATH"** — install Neovim ≥ 0.9:
Arch `sudo pacman -S neovim`, Debian/Ubuntu `sudo apt install neovim`
(use the appimage from GitHub releases on older suites), Fedora
`sudo dnf install neovim`.

**"wnvim needs Neovim >= 0.9"** — same as above; many distros ship very old
Neovim. The appimage or your distro's backports repo works everywhere.

**Verification failed at step 7/8** — the installer aborts *before* touching
plugin data and tells you where your backup lives. Nothing of yours was lost;
re-run after fixing (usually a partial copy — check disk space).

**Plugin bootstrap reported errors** — almost always "no network". Open
`wnvim` once; lazy.nvim retries automatically, or run `:Lazy sync`.

**`wnvim: command not found`** — the launcher went to `~/.local/bin`
(or your `--bin-dir`). Add it to PATH:
`export PATH="$HOME/.local/bin:$PATH"` (the installer already tries to do
this for bash/zsh/fish rc files; check `~/.bashrc` / `~/.zshrc`).

## Startup problems

**Slow first start** — normal: lazy.nvim clones and compiles plugins once.
Subsequent starts load from cache (`~/.cache/nvim/luac`).

**"Error detected while processing ... init.lua"** — capture it:
```sh
nvim --headless "+qa" 2>&1 | tee /tmp/wnvim-startup.log
```
Common causes: a plugin git-clone failure (offline) → `:Lazy restore`;
corrupt lazy state → delete `<data>/nvim/lazy/<plugin>` and restart.

**Plugins missing after update** — `:WnvimUpdate` (or `wnvim --update`) runs
`git pull --ff-only` + `Lazy sync` + `TSUpdate`. If your config dir is not a
git checkout (you installed by copying), re-run `install.sh` from a clone.

## Theme problems

**Theme doesn't change visually** — some terminals cache colors; the theme
system uses truecolor highlight groups, so ensure `TERM` supports it and
`termguicolors` stays enabled (wnvim sets it). Overriding colors via
`NVIM_...` terminal escapes can also mask highlights.

**`:WnvimThemeSet 99` rejected** — expected: unknown styles print
`[wnvim] unknown style: N` and keep the previous theme. Valid range is
1–10 (see docs/THEMES.md).

**Selection lost after reboot** — persistence lives in
`<stdpath("data")>/wnvim/state.json` (default
`~/.local/share/nvim/wnvim/state.json`). Check it exists and is readable;
a corrupt file falls back to Style 2 Night. In custom-shim mode the launcher
uses a temporary XDG root, so data written during shim sessions lands under
that temp dir — if you need persistence in custom mode, install with
`--appname` (uses `~/.local/share/wnvim/...` stably).

## LSP / completion / formatting

**No language server attaches** — open `:Mason`, install the server for your
language (needs `node`/`npm`/`python` etc. as prerequisites — Mason shows
missing ones). Default auto-installed set: lua_ls, bashls, pyright, marksman,
jsonls (see `lua/wnvim/lsp/servers.lua`).

**Completion menu doesn't appear** — press `<C-Space>` to trigger manually.
If still nothing: `:checkhealth lazy` and `:Lazy` (cmp loads on first insert).

**`<leader>lf` does nothing** — formatting requires either an LSP with
formatting capability or a CLI formatter present (black, stylua, shfmt,
prettierd, gofmt, rustfmt, clang-format, jq). none-ls registers only sources
whose binary exists — see `lua/wnvim/formatting.lua`. Install via Mason
(`stylua`, `shellcheck`, `prettierd`, `shfmt` are pre-seeded).

## Treesitter

**No highlighting in a file type** — parser not installed: `<leader>tI` then
type the filetype, or `:TSInstall <lang>`. Needs a C compiler (`cc`/`gcc`/
`clang`) and `git`.

**`:checkhealth treesitter` shows errors** — usually a missing parser; run
`<leader>tU` / `:TSUpdate`.

## Git signs missing

gitsigns only activates inside a git repository (`git init` first) and on
buffers read from disk. Reload the file (`:e`) after initializing the repo.

## Telescope slow / empty results

Install `ripgrep` (`rg`) for live-grep and `fd` for the file finder; without
them Telescope falls back to slower built-ins.

## Still broken?

Open an issue with the output of `wnvim --doctor` and
`nvim --headless "+qa" 2>&1` attached. See docs/RESTORE.md to get your old
Neovim setup back at any time.
