--[[
Core editor options. Every setting is commented so beginners can learn
and safely tweak. Nothing here depends on a plugin.
]]

local o = vim.opt

-- ── Numbers / lines ────────────────────────────────────────────────
o.number = true            -- absolute line number on cursor line
o.relativenumber = true    -- relative numbers elsewhere (great for counts)
o.signcolumn = 'yes'       -- always show sign column (no width jumps)
o.wrap = false             -- don't soft-wrap by default
o.linebreak = true         -- when wrapping, break on words

-- ── Editing behaviour ──────────────────────────────────────────────
o.expandtab = true         -- spaces instead of tabs
o.shiftwidth = 2           -- autoindent width
o.tabstop = 2              -- visual width of a tab
o.smartindent = true
o.breakindent = true
o.backspace = { 'start', 'eol', 'indent' }

-- ── Search ─────────────────────────────────────────────────────────
o.ignorecase = true        -- case-insensitive search...
o.smartcase = true         -- ...unless the pattern contains capitals
o.hlsearch = true
o.incsearch = true

-- ── Windows / splits ───────────────────────────────────────────────
o.splitright = true
o.splitbelow = true

-- ── Completion popup ───────────────────────────────────────────────
o.completeopt = { 'menu', 'menuone', 'noselect' }

-- ── Appearance ─────────────────────────────────────────────────────
o.termguicolors = true     -- 24-bit colors (theme system needs this)
o.cursorline = true
o.showmode = false         -- statusline shows it instead
o.ruler = false
o.laststatus = 3           -- global statusline
o.cmdheight = 1
o.shortmess:append('I')    -- suppress nvim start message (we show our own)
o.pumheight = 10           -- max completion items visible
o.scrolloff = 8            -- keep context lines around cursor
o.sidescrolloff = 8
o.wrapscan = true

-- ── Files ──────────────────────────────────────────────────────────
o.hidden = true            -- allow buffers with unsaved changes in background
o.confirm = true           -- prompt instead of silently dropping changes
o.undofile = true          -- persistent undo
o.swapfile = false
o.autoread = true

-- ── Performance ────────────────────────────────────────────────────
o.updatetime = 250         -- faster diagnostic / CursorHold events
o.timeoutlen = 500         -- which-key display delay
o.redrawtime = 1500
o.conceallevel = 0         -- don't hide text by default

-- ── Folds (treesitter-driven; works even before TS loads) ─────────
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldlevelstart = 99      -- start fully unfolded
o.fillchars:append({ fold = ' ' })

-- ── Clipboard ──────────────────────────────────────────────────────
if vim.fn.has('clipboard') == 1 then
  o.clipboard = 'unnamedplus'
end

-- ── Diff ───────────────────────────────────────────────────────────
o.diffopt:append('algorithm:myers')

-- Diagnostics UI defaults ------------------------------------------------
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = '●' },
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = true,
  signs = true,
})

if vim.fn.has('nvim-0.10') == 1 then
  vim.diagnostic.config({ jump = { float = true } })
end

-- Diagnostic sign icons (plain unicode — no patched-font dependency)
vim.fn.sign_define('DiagnosticSignError', { text = 'E', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn',  { text = 'W', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo',  { text = 'I', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint',  { text = 'H', texthl = 'DiagnosticSignHint' })
