--[[
=====================================================================
  wnvim — a polished, modular, beginner-friendly Neovim distribution
=====================================================================

  Entry point. Keep this file small: everything lives in lua/wnvim/.

  Load order matters:
    1. globals   (namespace, leader keys)
    2. options   (vim.opt / vim.g settings)
    3. theme     (reads persisted selection, loads base colorscheme)
    4. lazy      (plugin manager + all plugin specs)
    5. autocmds / keymaps (may reference plugins via `which-key` only)
    6. commands  (:WnvimTheme, :WnvimDoctor, ...)
    7. first-launch initialization (headless-safe)
=====================================================================
]]

-- Guard against being sourced twice (e.g. :source init.lua)
if vim.g.wnvim_loaded then
  return
end
vim.g.wnvim_loaded = true

local wnvim = require('wnvim.core.globals')
wnvim.version = '0.1.0'

require('wnvim.core.options')

-- Theme engine: must run BEFORE lazy so the base colorscheme is set
-- while plugins load (avoids a flash of default colors).
local theme = require('wnvim.themes')
theme.setup()

require('wnvim.plugins.lazy_setup')

require('wnvim.core.autocmds')
require('wnvim.core.keymaps')
require('wnvim.ui.commands').setup()

-- First-launch initialization -------------------------------------
-- If we were launched headlessly by the installer's post-install step,
-- do nothing extra here (the install script drives that process).
-- On the first *interactive* launch we make sure plugins are present.
if not wnvim.headless then
  local ok_lazy, lazy = pcall(require, 'lazy')
  if ok_lazy then
    -- Only trigger when the plugin dir doesn't exist yet (fresh clone
    -- without a prior install run). This is cheap and idempotent.
    local data = vim.fn.stdpath('data')
    if vim.fn.isdirectory(data .. '/lazy/lazy.nvim') == 0 then
      vim.schedule(function()
        vim.notify('[wnvim] First launch: installing plugins...', vim.log.levels.INFO)
        lazy.setup({ { 'folke/lazy.nvim', module = 'lazy' } }, { install = { colorscheme = { 'wnvim_default' } } })
      end)
    end
  end
end

-- Convenience: expose the version for --version / statusline
_G.wnvim_version = wnvim.version
