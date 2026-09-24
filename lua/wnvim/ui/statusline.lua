--[[
Statusline (lualine) sections that react to the wnvim theme.

Exposed as functions so both the lualine spec and any future custom
statusline can reuse them. Colors come from live highlight resolution
(`vim.api.nvim_get_hl` on >=0.10, `synIDattr` fallback otherwise), so
the bar always matches the current style+mode — day or night.
]]

local M = {}

--- Resolve a highlight group's fg/bg as "#rrggbb" strings.
--- Only used as a fallback when the theme engine has no active palette;
--- failures are non-fatal (lualine falls back to its own defaults).
local function hl_color(hlgroup, key)
  local ok, result = pcall(function()
    if vim.api.nvim_get_hl then
      local _, hl = pcall(vim.api.nvim_get_hl, 0, { name = hlgroup, link = false })
      if hl and hl[key] then
        return string.format('#%06x', hl[key])
      end
    end
    local id = vim.fn.hlID and vim.fn.hlID(hlgroup) or 0
    if id and id > 0 then
      local v = vim.fn.synIDattr(id, key)
      if v ~= '' and v ~= '-1' then
        return v:match('^#') and v or ('#' .. v)
      end
    end
    return nil
  end)
  if ok then return result end
  return nil
end

function M.colors()
  local theme = require('wnvim.themes')
  local p = theme.palette()
  if p then
    return {
      bg = p.bg_alt,
      fg = p.fg,
      accent = p.accent,
      accent_fg = p.bg,
      dim = p.comment,
      border = p.border,
    }
  end
  return {
    bg = hl_color('NormalFloat', 'bg') or '#282a2e',
    fg = hl_color('Normal', 'fg') or '#d4d4d4',
    accent = hl_color('Directory', 'fg') or '#61afef',
    accent_fg = hl_color('Normal', 'bg') or '#1e1e1e',
    dim = hl_color('NonText', 'fg') or '#7a7a7a',
    border = hl_color('WinSeparator', 'fg') or '#404040',
  }
end

-- ── components ──────────────────────────────────────────────────────

function M.mode()
  local names = {
    ['n'] = 'NORMAL', ['no'] = 'N·OP', ['v'] = 'VISUAL', ['V'] = 'V-LINE',
    ['\22'] = 'V-BLOCK', ['s'] = 'SELECT', ['S'] = 'S-LINE', ['^S'] = 'S-BLOCK',
    ['i'] = 'INSERT', ['ic'] = 'INS·COMP', ['ix'] = 'INS·XMAP',
    ['R'] = 'REPLACE', ['Rv'] = 'V·REPLACE', ['c'] = 'COMMAND', ['cv'] = 'EX',
    ['ce'] = 'EX', ['r'] = 'PROMPT', ['rm'] = 'MORE', ['r?'] = 'CONFIRM', ['!'] = 'SHELL',
  }
  return names[vim.fn.mode()] or vim.fn.mode():upper()
end

function M.git_branch()
  local ok, gs = pcall(require, 'gitsigns')
  if ok and gs.get_current_branch then
    return gs.get_current_branch() or ''
  end
  return ''
end

function M.diagnostics()
  local d = vim.diagnostic.count and vim.diagnostic.count(0) or nil
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }
  if d then
    counts.error = d[1] or 0
    counts.warn = d[2] or 0
    counts.info = d[3] or 0
    counts.hint = d[4] or 0
  else
    for _, diag in ipairs(vim.diagnostic.get(0)) do
      local s = diag.severity
      if s == 1 then counts.error = counts.error + 1
      elseif s == 2 then counts.warn = counts.warn + 1
      elseif s == 3 then counts.info = counts.info + 1
      elseif s == 4 then counts.hint = counts.hint + 1 end
    end
  end
  local parts = {}
  if counts.error > 0 then parts[#parts + 1] = 'E' .. counts.error end
  if counts.warn > 0 then parts[#parts + 1] = 'W' .. counts.warn end
  if counts.info > 0 then parts[#parts + 1] = 'I' .. counts.info end
  if counts.hint > 0 then parts[#parts + 1] = 'H' .. counts.hint end
  return table.concat(parts, ' ')
end

function M.theme_label()
  local theme = require('wnvim.themes')
  local cur = theme.current()
  if not cur then return '' end
  local st = theme.styles()[cur.style]
  local icon = (cur.mode == 'day') and 'Day' or 'Night'
  return string.format('%s · %s', st.name, icon)
end

return M
