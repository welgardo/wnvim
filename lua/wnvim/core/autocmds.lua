--[[
Core autocommands. All grouped under the `wnvim` augroup so they can be
reloaded cleanly and never leak into a user's plain `nvim`.
]]

local aug = vim.api.nvim_create_augroup('wnvim', { clear = true })

-- Highlight the yanked text briefly.
vim.api.nvim_create_autocmd('TextYankPost', {
  group = aug,
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 150 })
  end,
})

-- Return to the last cursor position when reopening a file.
vim.api.nvim_create_autocmd('BufReadPost', {
  group = aug,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close quickfix/popup-style windows with q <Esc> etc.
vim.api.nvim_create_autocmd('FileType', {
  group = aug,
  pattern = { 'qf', 'help' },
  callback = function(ev)
    local buf = ev.buf
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, nowait = true, silent = true })
    if ev.match == 'qf' then
      vim.bo[buf].buflisted = false
    end
  end,
})

-- Resize splits proportionally when the Neovim window is resized.
vim.api.nvim_create_autocmd('VimResized', {
  group = aug,
  callback = function()
    vim.cmd('tabdo wincmd =')
  end,
})

-- Strip trailing whitespace on save (safe for most languages).
vim.api.nvim_create_autocmd('BufWritePre', {
  group = aug,
  pattern = '*',
  callback = function()
    -- Preserve cursor position while substituting.
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Go back to previous directory when closing the file explorer.
vim.api.nvim_create_autocmd('User', {
  group = aug,
  pattern = 'NeotreeClose',
  callback = function()
    -- If no other visible window besides terminal-like ones remains, quit.
    local ok, api = pcall(require, 'neo-tree.api')
    if not ok then return end
    _ = api
  end,
})

-- Set `keywordprg` to K via LSP by default — nothing needed; keep hook.
vim.api.nvim_create_autocmd('LspAttach', {
  group = aug,
  callback = function(ev)
    require('wnvim.lsp').on_attach(ev)
  end,
})
