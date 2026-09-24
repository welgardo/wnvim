--[[
Small shared helpers used across wnvim. Dependency-free (core Neovim only).
]]

local M = {}

-- Notify with a consistent prefix.
function M.notify(msg, level)
  vim.schedule(function()
    vim.notify('[wnvim] ' .. msg, level or vim.log.levels.INFO)
  end)
end

-- Version-aware diagnostic navigation (vim.diagnostic.jump is >=0.10;
-- older builds use the deprecated goto_* functions).
function M.diag_jump(count)
  if vim.diagnostic.jump then
    pcall(vim.diagnostic.jump, { count = count, float = true })
  else
    if count < 0 then
      vim.diagnostic.goto_prev({ float = true })
    else
      vim.diagnostic.goto_next({ float = true })
    end
  end
end

-- Resolve a dotted color like "Normal.bg" from a palette table.
function M.pluck(t, path)
  local cur = t
  for part in path:gmatch('[%w_]+') do
    if type(cur) ~= 'table' then return nil end
    cur = cur[part]
  end
  return cur
end

-- Apply a list of highlight groups with wnvim's namespace so repeated
-- applications replace previous ones cleanly.
M.hl_ns = vim.api.nvim_create_namespace('wnvim_theme')
function M.hlset(defs)
  for name, def in pairs(defs) do
    local ok = pcall(vim.api.nvim_set_hl, 0, name, def)
    if not ok then
      vim.defer_fn(function()
        pcall(vim.api.nvim_set_hl, 0, name, def)
      end, 50)
    end
  end
end

-- Clear all wnvim highlight overrides (before re-applying a new theme).
function M.hlclear()
  pcall(vim.api.nvim_buf_clear_namespace, 0, M.hl_ns, 0, -1)
end

-- Run an external command safely; returns success, output-lines.
function M.system(cmd)
  local ok, out = pcall(vim.system, cmd, { text = true }, function(r)
    M._last_rc = r.code
  end)
  if not ok then
    -- Fallback for very old nightly builds without vim.system
    local res = vim.fn.system(cmd)
    return vim.v.shell_error == 0, vim.split(res, '\n', { plain = true })
  end
  return true, out
end

return M
