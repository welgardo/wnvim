# Restoring Your Previous Neovim Configuration

wnvim is designed so that **nothing of yours is ever deleted**. This document
explains exactly what the installer touched and how to undo it — automatically
or by hand.

## What the installer does with your existing config

When you had a config at `~/.config/nvim` (or `$XDG_CONFIG_HOME/nvim`) and
installed in **standard** mode, the installer *moved* (never copied-and-deleted)
it to:

```
~/.local/share/wnvim/backups/nvim.<YYYYMMDD-HHMMSS>/
```

Every run creates a new timestamped directory; previous backups are never
overwritten. The most recent backup path is also recorded in
`~/.local/share/wnvim/backups/latest`.

In **custom** mode (`--custom`, the default when an existing config is found
and you accept the recommendation), your `~/.config/nvim` is never touched at
all — wnvim lives in its own directory and only the `wnvim` launcher command
is added. Nothing to restore.

The full record of what was changed lives in the install manifest:

```
~/.local/share/wnvim/install.manifest
```

with keys `MODE`, `TARGET_DIR`, `BACKUP`, `LAUNCHER`, `LAUNCHER_SHA256`,
`USE_APPNAME`, `XDG_CONFIG_HOME`, `INSTALLED_AT`.

## Automatic uninstall (recommended)

From the shell:

```sh
wnvim --uninstall
```

or from a clone of this repository:

```sh
./uninstall.sh            # asks for confirmation first
./uninstall.sh --yes      # non-interactive
./uninstall.sh --dry-run  # show what would happen, change nothing
./uninstall.sh --keep-backups   # remove wnvim but leave backups untouched
```

The uninstaller:

1. Removes the `wnvim` launcher **only if its SHA-256 still matches** what we
   installed (a file you edited is left alone with a warning).
2. Removes wnvim's private data dirs under `~/.local/share/wnvim/`
   (`lazy/`, `state/`, `logs/`) — these contain only files wnvim created.
3. Removes the installed wnvim config dir **only if it still looks like
   wnvim** (contains `lua/wnvim/themes/styles.lua`). A config you or another
   tool replaced afterwards is never deleted.
4. Restores your backup: moves `backups/nvim.<timestamp>` back to
   `~/.config/nvim`. If something already exists there again, it **refuses to
   overwrite** and prints the exact manual command instead.
5. Deletes the shared plugin dir? **No** — `~/.local/share/nvim/lazy` may be
   used by other configs, so the uninstaller only warns about it and shows a
   manual removal command if you want it gone.

## Manual restore (no uninstaller needed)

To go back to your old setup immediately:

```sh
rm -rf ~/.config/nvim                 # removes the wnvim config (standard mode only!)
mv ~/.local/share/wnvim/backups/nvim.<TIMESTAMP> ~/.config/nvim
```

Find `<TIMESTAMP>` with:

```sh
ls ~/.local/share/wnvim/backups/
cat ~/.local/share/wnvim/backups/latest    # newest backup path
```

Then delete the launcher if you no longer want it:

```sh
rm ~/.local/bin/wnvim        # or wherever install.sh put it (see manifest LAUNCHER=)
```

Your old plugins/data in `~/.local/share/nvim` were never modified by the
installer, so after restoring the config everything should work as before.

## Keeping both (best of both worlds)

You don't have to choose. Re-install in custom mode and your original config
stays active for plain `nvim`, while wnvim runs via its own command:

```sh
git clone <your-wnvim-repository-url> && cd wnvim
./install.sh --custom            # or: ./install.sh --custom --appname
```

- Default custom mode: wnvim in `~/.local/share/wnvim/config`, launched
  through a temporary XDG shim.
- `--appname`: wnvim in `$XDG_CONFIG_HOME/wnvim`, launched via
  `NVIM_APPNAME=wnvim` (fully separate data/state dirs, persistent theme
  selection).

## Verifying nothing was lost

Before and after any operation you can list every backup ever made:

```sh
ls -la ~/.local/share/wnvim/backups/
```

wnvim has no code path that deletes user configuration; the only destructive
operations are on paths the installer itself created, each guarded by an
explicit "is this ours?" check.
