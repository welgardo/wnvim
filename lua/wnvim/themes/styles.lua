--[[
wnvim style registry — declarative palettes for 10 styles × day/night.

Each entry has a `day` and `night` palette. A palette contains every
color the theme engine needs; NOTHING here is computed by string hacks,
so adding an 11th style = adding one table entry (see docs/THEMES.md).

Palette keys:
  bg          default background
  bg_alt      statusline / sidebars / non-text surfaces
  bg_visual   selection background
  bg_search   search highlight background
  fg          default foreground
  fg_gutter   line numbers, non-current signs
  black red green yellow blue magenta cyan white
              ANSI-ish set used to derive syntax groups
  comment     comments (usually muted)
  cursor      cursor line/column color
  border      window borders
  accent      brand color (statusline sections, which-key labels)
  error warn info hint   diagnostic colors
]]

return {
  -- ── Style 1: Minimal ───────────────────────────────────────────
  -- Soft paper/ink look. Low contrast, no italics, quiet.
  [1] = {
    name = 'Minimal',
    tagline = 'Quiet paper-and-ink editing, zero noise',
    italic = false,
    day = {
      bg = '#fbf8f3', bg_alt = '#efe9df', bg_visual = '#e3dccd', bg_search = '#f5e3b8',
      fg = '#3a3733', fg_gutter = '#b8b0a2',
      black = '#6b675f', red = '#a8423e', green = '#4c7a4f', yellow = '#9a7330',
      blue = '#3f6b91', magenta = '#7d5387', cyan = '#417a77', white = '#3a3733',
      comment = '#a39b8d', cursor = '#3a3733', border = '#ddd5c8',
      accent = '#8a6d3b', error = '#a8423e', warn = '#9a7330', info = '#3f6b91', hint = '#4c7a4f',
    },
    night = {
      bg = '#1d1e20', bg_alt = '#26282b', bg_visual = '#34373c', bg_search = '#4a4433',
      fg = '#d4d2cd', fg_gutter = '#5c5e63',
      black = '#8a8c90', red = '#d98d84', green = '#9cc49b', yellow = '#d9bc7f',
      blue = '#8ab4d8', magenta = '#c09ac9', cyan = '#8ac9c4', white = '#d4d2cd',
      comment = '#6f7176', cursor = '#d4d2cd', border = '#3a3d42',
      accent = '#c9a86a', error = '#d98d84', warn = '#d9bc7f', info = '#8ab4d8', hint = '#9cc49b',
    },
  },

  -- ── Style 2: Tokyo Neon ────────────────────────────────────────
  -- Cool night-city blues with electric accents (tokyonight-inspired,
  -- our own palette values).
  [2] = {
    name = 'Tokyo Neon',
    tagline = 'Electric blues from a neon cityscape',
    italic = true,
    day = {
      bg = '#f5f7fc', bg_alt = '#e6ebf5', bg_visual = '#cddcf5', bg_search = '#f7dca8',
      fg = '#35416f', fg_gutter = '#9aa8c7',
      black = '#35416f', red = '#db5c7c', green = '#309c78', yellow = '#b07e00',
      blue = '#376bd0', magenta = '#9a5ad0', cyan = '#2e82aa', white = '#dbe1f0',
      comment = '#8f9fbe', cursor = '#376bd0', border = '#bcc8e4',
      accent = '#7c5cff', error = '#db5c7c', warn = '#b07e00', info = '#376bd0', hint = '#309c78',
    },
    night = {
      bg = '#161823', bg_alt = '#1e2130', bg_visual = '#2f3452', bg_search = '#3d3a52',
      fg = '#c0caf5', fg_gutter = '#3b4261',
      black = '#161823', red = '#f55c8a', green = '#2fc98a', yellow = '#e5b564',
      blue = '#6aa8ff', magenta = '#c792ea', cyan = '#34cdc9', white = '#c0caf5',
      comment = '#565f89', cursor = '#6aa8ff', border = '#2f3352',
      accent = '#bb9af7', error = '#f55c8a', warn = '#e5b564', info = '#6aa8ff', hint = '#2fc98a',
    },
  },

  -- ── Style 3: Cyberpunk ─────────────────────────────────────────
  -- Hot pink vs. acid cyan on near-black; high-voltage, loud.
  [3] = {
    name = 'Cyberpunk',
    tagline = 'High-voltage magenta and acid cyan',
    italic = true,
    day = {
      bg = '#fff7fa', bg_alt = '#ffe3ee', bg_visual = '#ffc2d8', bg_search = '#ffe08a',
      fg = '#4a1033', fg_gutter = '#c98aa8',
      black = '#4a1033', red = '#e0145e', green = '#00a86b', yellow = '#d98e00',
      blue = '#0077c2', magenta = '#d4008f', cyan = '#00b3b3', white = '#4a1033',
      comment = '#b56a8a', cursor = '#d4008f', border = '#f5b8d0',
      accent = '#ff2d78', error = '#e0145e', warn = '#d98e00', info = '#0077c2', hint = '#00a86b',
    },
    night = {
      bg = '#0b0714', bg_alt = '#170d26', bg_visual = '#3d1155', bg_search = '#55300f',
      fg = '#f2e9ff', fg_gutter = '#5a3a78',
      black = '#0b0714', red = '#ff2e63', green = '#08f7fe', yellow = '#f7d308',
      blue = '#059aff', magenta = '#ff00ff', cyan = '#00fff5', white = '#f2e9ff',
      comment = '#7a5c9e', cursor = '#08f7fe', border = '#3d1f5c',
      accent = '#ff2e63', error = '#ff2e63', warn = '#f7d308', info = '#059aff', hint = '#08f7fe',
    },
  },

  -- ── Style 4: Nord Ice ──────────────────────────────────────────
  -- The beloved arctic Nord palette (documented official hex values;
  -- CC0-licensed palette data).
  [4] = {
    name = 'Nord Ice',
    tagline = 'Arctic calm, polar night blues',
    italic = false,
    day = {
      bg = '#eceff4', bg_alt = '#e5e9f0', bg_visual = '#d8dee9', bg_search = '#ebcb8b',
      fg = '#2e3440', fg_gutter = '#9ba5b5',
      black = '#3b4252', red = '#bf616a', green = '#a3be8c', yellow = '#ebcb8b',
      blue = '#5e81ac', magenta = '#b48ead', cyan = '#88c0d0', white = '#e5e9f0',
      comment = '#a7b0c0', cursor = '#5e81ac', border = '#c8d0dd',
      accent = '#5e81ac', error = '#bf616a', warn = '#d08770', info = '#5e81ac', hint = '#a3be8c',
    },
    night = {
      bg = '#2e3440', bg_alt = '#3b4252', bg_visual = '#434c5e', bg_search = '#4c566a',
      fg = '#d8dee9', fg_gutter = '#616e88',
      black = '#3b4252', red = '#bf616a', green = '#a3be8c', yellow = '#ebcb8b',
      blue = '#81a1c1', magenta = '#b48ead', cyan = '#88c0d0', white = '#e5e9f0',
      comment = '#616e88', cursor = '#88c0d0', border = '#434c5e',
      accent = '#88c0d0', error = '#bf616a', warn = '#ebcb8b', info = '#81a1c1', hint = '#a3be8c',
    },
  },

  -- ── Style 5: Gruvbox Warm ──────────────────────────────────────
  -- Retro warm earth tones (gruvbox-style direction, own values).
  [5] = {
    name = 'Gruvbox Warm',
    tagline = 'Retro groove, warm earth tones',
    italic = false,
    day = {
      bg = '#f2e5c4', bg_alt = '#ebdbb2', bg_visual = '#d5c4a1', bg_search = '#fabd2f',
      fg = '#3c3836', fg_gutter = '#a89984',
      black = '#3c3836', red = '#cc241d', green = '#98971a', yellow = '#d79921',
      blue = '#458588', magenta = '#b16286', cyan = '#689d6a', white = '#a89984',
      comment = '#928374', cursor = '#af5f00', border = '#d5c4a1',
      accent = '#af5f00', error = '#cc241d', warn = '#d79921', info = '#458588', hint = '#98971a',
    },
    night = {
      bg = '#1d2021', bg_alt = '#282828', bg_visual = '#3c3836', bg_search = '#4a3f24',
      fg = '#ebdbb2', fg_gutter = '#665c54',
      black = '#3c3836', red = '#fb4934', green = '#b8bb26', yellow = '#fabd2f',
      blue = '#83a598', magenta = '#d3869b', cyan = '#8ec07c', white = '#ebdbb2',
      comment = '#928374', cursor = '#fe8019', border = '#3c3836',
      accent = '#fe8019', error = '#fb4934', warn = '#fabd2f', info = '#83a598', hint = '#b8bb26',
    },
  },

  -- ── Style 6: Monochrome ────────────────────────────────────────
  -- Pure grayscale + one steel-blue accent. Maximum focus.
  [6] = {
    name = 'Monochrome',
    tagline = 'Grayscale focus, one cold accent',
    italic = false,
    day = {
      bg = '#fafafa', bg_alt = '#ededed', bg_visual = '#dcdcdc', bg_search = '#f0e6c8',
      fg = '#1a1a1a', fg_gutter = '#a8a8a8',
      black = '#1a1a1a', red = '#6e6e6e', green = '#4f4f4f', yellow = '#8a8a8a',
      blue = '#2f4a68', magenta = '#5a5a5a', cyan = '#3f5a6e', white = '#f5f5f5',
      comment = '#9a9a9a', cursor = '#1a1a1a', border = '#cfcfcf',
      accent = '#2f4a68', error = '#1a1a1a', warn = '#6e6e6e', info = '#2f4a68', hint = '#4f4f4f',
    },
    night = {
      bg = '#111111', bg_alt = '#1c1c1c', bg_visual = '#2e2e2e', bg_search = '#3a3a2a',
      fg = '#e2e2e2', fg_gutter = '#585858',
      black = '#e2e2e2', red = '#9e9e9e', green = '#b0b0b0', yellow = '#c8c8c8',
      blue = '#7fa5c9', magenta = '#8a8a8a', cyan = '#93b3bf', white = '#e2e2e2',
      comment = '#666666', cursor = '#e2e2e2', border = '#333333',
      accent = '#7fa5c9', error = '#ffffff', warn = '#c8c8c8', info = '#7fa5c9', hint = '#b0b0b0',
    },
  },

  -- ── Style 7: Matrix ────────────────────────────────────────────
  -- Green phosphor terminal. Day mode = "printed terminal log" on paper-green.
  [7] = {
    name = 'Matrix',
    tagline = 'Green phosphor terminal dreams',
    italic = false,
    day = {
      bg = '#eef7ee', bg_alt = '#dcf0dc', bg_visual = '#bfe6c4', bg_search = '#e8e6a8',
      fg = '#0c3a14', fg_gutter = '#7fae87',
      black = '#0c3a14', red = '#7a4a00', green = '#1d7a2c', yellow = '#6b6b00',
      blue = '#22688a', magenta = '#5a2d7a', cyan = '#177a6a', white = '#0c3a14',
      comment = '#88b890', cursor = '#1d7a2c', border = '#b5dcb9',
      accent = '#1d7a2c', error = '#a03030', warn = '#6b6b00', info = '#22688a', hint = '#177a6a',
    },
    night = {
      bg = '#030a03', bg_alt = '#08140a', bg_visual = '#0f2e15', bg_search = '#243a10',
      fg = '#33dd55', fg_gutter = '#1a5c28',
      black = '#08140a', red = '#e05555', green = '#33ff66', yellow = '#d7d733',
      blue = '#33b1ff', magenta = '#b04ae0', cyan = '#28e0c8', white = '#c8ffd4',
      comment = '#1f8a35', cursor = '#33ff66', border = '#14401c',
      accent = '#33ff66', error = '#e05555', warn = '#d7d733', info = '#33b1ff', hint = '#28e0c8',
    },
  },

  -- ── Style 8: Pastel ────────────────────────────────────────────
  -- Soft candy tones, low saturation, friendly (catppuccin direction).
  [8] = {
    name = 'Pastel',
    tagline = 'Soft candy colors, easy on the eyes',
    italic = true,
    day = {
      bg = '#f7f2f5', bg_alt = '#ede4ec', bg_visual = '#e0cfe0', bg_search = '#f5e3b8',
      fg = '#575268', fg_gutter = '#b3aabf',
      black = '#575268', red = '#d8576b', green = '#4da36e', yellow = '#d9a441',
      blue = '#5e7fd4', magenta = '#b06fc9', cyan = '#4aa8b8', white = '#f7f2f5',
      comment = '#a49bb0', cursor = '#b06fc9', border = '#d8cede',
      accent = '#c26fd0', error = '#d8576b', warn = '#d9a441', info = '#5e7fd4', hint = '#4da36e',
    },
    night = {
      bg = '#201e2b', bg_alt = '#2a2739', bg_visual = '#3b3651', bg_search = '#4a4160',
      fg = '#dcd4e8', fg_gutter = '#5c5672',
      black = '#6e6785', red = '#f5a0ab', green = '#a3d8b0', yellow = '#f2d5a0',
      blue = '#a5b8f0', magenta = '#d8b0f0', cyan = '#98dae2', white = '#dcd4e8',
      comment = '#7a7393', cursor = '#d8b0f0', border = '#3b3651',
      accent = '#cba6f7', error = '#f5a0ab', warn = '#f2d5a0', info = '#a5b8f0', hint = '#a3d8b0',
    },
  },

  -- ── Style 9: Material ──────────────────────────────────────────
  -- Google Material design direction: teal/orange on blue-grey.
  [9] = {
    name = 'Material',
    tagline = 'Design-system blues, teal and amber',
    italic = false,
    day = {
      bg = '#eaedf2', bg_alt = '#dde2ea', bg_visual = '#c3d3e8', bg_search = '#ffe9b0',
      fg = '#25303b', fg_gutter = '#93a1b0',
      black = '#25303b', red = '#c52f57', green = '#1a9d5c', yellow = '#b87e0a',
      blue = '#1f77c8', magenta = '#8e3fc0', cyan = '#0091a8', white = '#dde2ea',
      comment = '#8296a8', cursor = '#1f77c8', border = '#bcc9d6',
      accent = '#0091a8', error = '#c52f57', warn = '#b87e0a', info = '#1f77c8', hint = '#1a9d5c',
    },
    night = {
      bg = '#19212b', bg_alt = '#212b38', bg_visual = '#2e4054', bg_search = '#4a4326',
      fg = '#d9e4ee', fg_gutter = '#4d6275',
      black = '#212b38', red = '#f07178', green = '#c3e88d', yellow = '#ffcb6b',
      blue = '#82aaff', magenta = '#c792ea', cyan = '#89ddff', white = '#d9e4ee',
      comment = '#5c7387', cursor = '#ffcb6b', border = '#2e4054',
      accent = '#89ddff', error = '#f07178', warn = '#ffcb6b', info = '#82aaff', hint = '#c3e88d',
    },
  },

  -- ── Style 10: Futuristic ───────────────────────────────────────
  -- Deep-space violet with hologram teal; sci-fi HUD feel.
  [10] = {
    name = 'Futuristic',
    tagline = 'Deep-space HUD, hologram teal',
    italic = true,
    day = {
      bg = '#f2f4fb', bg_alt = '#e4e8f7', bg_visual = '#ccd6f2', bg_search = '#f3e0c0',
      fg = '#2c2f52', fg_gutter = '#9aa2c8',
      black = '#2c2f52', red = '#d43a6a', green = '#12a594', yellow = '#c98a2b',
      blue = '#4457d6', magenta = '#8a4fd0', cyan = '#0fb8d4', white = '#f2f4fb',
      comment = '#8d95bd', cursor = '#0fb8d4', border = '#c4cce8',
      accent = '#4457d6', error = '#d43a6a', warn = '#c98a2b', info = '#4457d6', hint = '#12a594',
    },
    night = {
      bg = '#0a0c1c', bg_alt = '#12152b', bg_visual = '#232a52', bg_search = '#3d3a1f',
      fg = '#dce2ff', fg_gutter = '#3d4470',
      black = '#12152b', red = '#ff5c8a', green = '#1de9b6', yellow = '#ffd166',
      blue = '#5c7cff', magenta = '#b45cff', cyan = '#00e5ff', white = '#dce2ff',
      comment = '#525a8c', cursor = '#00e5ff', border = '#232a52',
      accent = '#00e5ff', error = '#ff5c8a', warn = '#ffd166', info = '#5c7cff', hint = '#1de9b6',
    },
  },
}
