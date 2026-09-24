--[[
lazy.nvim bootstrap + spec loader.

Self-installs lazy.nvim into <data>/lazy/lazy.nvim on first run without
requiring curl/git beyond what Neovim's own loop can do (we use git,
which is a hard dependency checked by the installer).
]]

local M = {}

function M.bootstrap()
  local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.notify('[wnvim] Bootstrapping lazy.nvim...', vim.log.levels.INFO)
    local ok, err = pcall(function()
      vim.fn.system({
        'git', 'clone', '--filter=blob:none', '--branch=v10.5.1',
        'https://github.com/folke/lazy.nvim.git', '--quiet', lazypath,
      })
    end)
    if not ok or vim.v.shell_error ~= 0 or not (vim.uv or vim.loop).fs_stat(lazypath .. '/lua/lazy/init.lua') then
      vim.notify(
        '[wnvim] Could not bootstrap lazy.nvim (' .. tostring(err or 'git clone failed') .. ').'
        .. ' Check your network and that `git` is installed. Editor still usable without plugins.',
        vim.log.levels.ERROR)
      return false
    end
  end
  vim.opt.rtp:prepend(lazypath)
  return true
end

--- Load every file in lua/wnvim/plugins/specs/*.lua as a spec list.
local function collect_specs()
  local specs = {}
  local dir = debug.getinfo(1, 'S').source:sub(2):match('(.*/)') .. 'specs'
  -- Fallback: search runtimepath for the specs directory so this works
  -- whether wnvim lives at ~/.config/nvim or elsewhere.
  local found = (vim.uv or vim.loop).fs_stat(dir)
  if not found then
    for _, p in ipairs(vim.api.nvim_get_runtime_file('lua/wnvim/plugins/specs', true)) do
      dir = p
      found = true
      break
    end
  end
  if not found then
    return specs
  end

  local files = {}
  local handle = vim.fn.globpath(dir, '*.lua', false, true)
  for _, f in ipairs(handle) do
    files[#files + 1] = f
  end
  table.sort(files) -- deterministic load order

  for _, f in ipairs(files) do
    local mod = f:match('([^/]+)%.lua$')
    local ok, chunk = pcall(require, 'wnvim.plugins.specs.' .. mod)
    if ok then
      if type(chunk) == 'table' then
        for _, spec in ipairs(chunk) do
          specs[#specs + 1] = spec
        end
      else
        specs[#specs + 1] = chunk
      end
    else
      vim.notify('[wnvim] Failed to load plugin spec ' .. mod .. ': ' .. tostring(chunk),
        vim.log.levels.ERROR)
    end
  end
  return specs
end

M.collect_specs = collect_specs

return M
