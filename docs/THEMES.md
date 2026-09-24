# wnvim Themes

wnvim ships **10 visual styles**, each with a **Day** and a **Night** variant —
20 selectable configurations in total. All palettes are hand-authored inside
this repository (`lua/wnvim/themes/styles.lua`), so no third-party colorscheme
plugins are required and there are no licensing entanglements.

## Selecting a theme

Inside Neovim:

| Command | Effect |
|---|---|
| `:WnvimTheme` (alias `:WnvimThemeSelect`) | Two-step picker: choose a style, then Day/Night |
| `:WnvimThemeDay` | Switch the current style to its Day palette |
| `:WnvimThemeNight` | Switch the current style to its Night palette |
| `:WnvimThemeNext` / `:WnvimThemePrev` | Cycle through styles 1–10, keeping Day/Night |
| `:WnvimThemeSet {1-10} [day\|night]` | Set directly, e.g. `:WnvimThemeSet 5 night` |

Keymap: `<Space> t h` opens the same picker (a dependency-free floating
window with live preview while navigating — it works even on the very first
launch, before any plugins are installed).

Tab-completion is wired for `:WnvimThemeSet`.

## The 10 styles

| # | Name | Character |
|---|------|-----------|
| 1 | Minimal | Quiet paper-and-ink, low contrast, no italics |
| 2 | Tokyo Neon | Cool night-city blues, electric accents |
| 3 | Cyberpunk | High-saturation magenta/cyan on near-black |
| 4 | Nord Ice | Icy blue-grey, soft and cold |
| 5 | Gruv Warm | Warm retro earth tones |
| 6 | Monochrome | Pure greyscale, hierarchy by weight only |
| 7 | Matrix | Terminal green-on-dark phosphor look |
| 8 | Pastel | Soft pastel tints, gentle day mode |
| 9 | Material | Material-design blue/orange surfaces |
| 10 | Futuristic | Deep space indigo with holographic accents |

Each style defines two complete palettes (`day` and `night`). Every palette
specifies background, foreground, gutter, selection, search, border, accent,
ANSI set, and diagnostic colors — see the header comment of
`lua/wnvim/themes/styles.lua` for the key list.

## Persistence

Your selection is stored as JSON at:

```
<stdpath("data")>/wnvim/state.json      # usually ~/.local/share/nvim/wnvim/state.json
```

It survives restarts and `git pull` updates (the file lives outside the repo).
If the file is missing or corrupt, wnvim falls back to **Style 2 (Tokyo Neon),
Night**. An invalid style number or mode string is rejected with a notification
and the previous valid state is kept.

If no saved selection exists, the environment variables `WNVIM_THEME_STYLE`
(number) and `WNVIM_THEME_MODE` (`day`/`night`) are used as defaults before
falling back to Style 2 / Night. The saved state file always wins over them.

## Adding an 11th style

No code changes are needed anywhere except the registry. Append one entry to
the table returned by `lua/wnvim/themes/styles.lua`:

```lua
[11] = {
  name = 'Sunset',
  tagline = 'Amber horizon gradients',
  italic = true,
  day   = { bg = '...', fg = '...', ... },   -- every palette key, see styles.lua header
  night = { bg = '...', fg = '...', ... },
},
```

The picker, `:WnvimThemeSet`, cycle commands, statusline label, and installer
verification all iterate over the registry automatically.

## How it renders

`lua/wnvim/themes/init.lua` converts a palette into ~150+ highlight groups
(editor core, syntax, LSP/diagnostic virtual text, Telescope, cmp menus,
Pmenu, floats, borders, NeoTree, gitsigns, which-key) and applies them with
`nvim_set_hl`. The lualine statusline reads the live palette and rebuilds
itself whenever the `User WnvimThemeChanged` event fires, so switching themes
is instant and requires no restart.
