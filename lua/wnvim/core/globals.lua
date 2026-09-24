--[[
wnvim global namespace and leader keys.

Everything wnvim owns lives under the `wnvim` Lua module namespace and
the `g:wnvim_*` Vim globals, so we never collide with user settings.
]]

local M = {}

-- Headless detection (the installer runs `nvim --headless`).
-- We check whether stdin is a TTY: interactive launches always have one.
M.headless = true
pcall(function()
  local uv = vim.uv or vim.loop
  local fd = uv.new_tty(0, false)
  if fd then
    M.headless = not fd:is_tty()
    fd:close()
  end
end)

-- Leader keys (set BEFORE any plugin loads — lazy.nvim reads them at setup).
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Mark that this Neovim instance is running the wnvim distro.
vim.g.wnvim_distro = true

-- Shared namespace for other modules.
_G.wnvim = M

return M
