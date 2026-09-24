--[[
Core keymaps that do NOT depend on any plugin. Plugin-specific keymaps
live next to their plugin spec. Which-key labels are registered in the
specs so this file stays dependency-free.
]]

local map = vim.keymap.set

local M = {}

-- ── Sanity / escape hatches ────────────────────────────────────────
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight', silent = true })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Terminal > normal mode' })

-- ── Window navigation (plain keys, no plugin needed) ──────────────
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- ── Resizing ───────────────────────────────────────────────────────
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save file' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit window' })
map('n', '<leader>-', '<cmd>split<cr>', { desc = 'Split horizontal' })
map('n', '<leader>|', '<cmd>vsplit<cr>', { desc = 'Split vertical' })

-- ── Buffer navigation ──────────────────────────────────────────────
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })

-- ── Diagnostics (native) ───────────────────────────────────────────
map('n', '[d', function() require('wnvim.utils').diag_jump(-1) end, { desc = 'Prev diagnostic' })
map('n', ']d', function() require('wnvim.utils').diag_jump(1) end, { desc = 'Next diagnostic' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
-- <leader>d group (which-key: "diagnostics"): <leader>dl sends buffer
-- diagnostics to the location list; LSP-spec adds <leader>ds (telescope).
map('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

-- ── Move selected text (visual) ────────────────────────────────────
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Keep cursor centered-ish when half-page scrolling
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

-- Better marks
map('n', '<leader>a', '<cmd>keepjumps normal! ggVG<cr>', { desc = 'Select all' })

-- Reload config
map('n', '<leader>R', '<cmd>source $MYVIMRC<cr>', { desc = 'Reload config' })

return M
