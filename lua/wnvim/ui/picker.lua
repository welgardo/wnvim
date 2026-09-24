--[[
Theme selection UI.

Two-step picker:
  Step 1: pick one of the 10 styles (live preview as you move the cursor)
  Step 2: pick Day or Night

Implemented with a custom Neovim float buffer so it works on every
supported Neovim version with ZERO plugin dependencies — including the
very first launch before lazy.nvim has installed anything.

Public API:
  M.select()    open interactive two-step picker
  M.set_day() / M.set_night()
]]

local theme = require('wnvim.themes')
local utils = require('wnvim.utils')
local persist = require('wnvim.utils.persist')

local M = {}

-- ── data helpers ────────────────────────────────────────────────────

local function style_entries()
  local entries = {}
  local styles = theme.styles()
  local i = 1
  while styles[i] do
    entries[#entries + 1] = { idx = i, name = styles[i].name, tagline = styles[i].tagline }
    i = i + 1
  end
  return entries
end

-- ── generic single-select float picker ──────────────────────────────
--- items: list of { display = string, value = any }
--- opts:  { title, footer, on_select(value), on_preview(value) }
--- Calls opts.on_cancel() if the user leaves without selecting.
local function open_picker(items, opts)
  opts = opts or {}

  -- Clean up any previous instance of our picker.
  if M._picker_buf and vim.api.nvim_buf_is_valid(M._picker_buf) then
    pcall(vim.api.nvim_buf_delete, M._picker_buf, { force = true })
  end
  M._picker_buf = nil

  local buf = vim.api.nvim_create_buf(false, true)
  M._picker_buf = buf

  local width = 0
  for _, it in ipairs(items) do
    width = math.max(width, vim.fn.strdisplaywidth(it.display))
  end
  width = math.min(math.max(width + 4, 44), 78)

  local height = #items + 3 -- blank + list + blank (title/footer are borders)
  local ui = vim.api.nvim_list_uis()[1]
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.max(row, 1),
    col = math.max(col, 1),
    width = width,
    height = height,
    border = 'rounded',
    style = 'minimal',
    title = ' ' .. (opts.title or 'wnvim') .. ' ',
    title_pos = 'center',
    footer = ' ' .. (opts.footer or '<CR> select   <Esc> cancel') .. ' ',
    footer_pos = 'center',
  })

  local lines = { '' }
  for _, it in ipairs(items) do
    lines[#lines + 1] = '  ' .. it.display
  end
  lines[#lines + 1] = ''
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'

  vim.wo[win][0].cursorline = true
  vim.wo[win][0].winhighlight = 'Normal:NormalFloat,EndOfBuffer:NormalFloat,CursorLine:CursorLine'
  vim.api.nvim_win_set_cursor(win, { 2, 0 })

  local selected = false

  local function current_value()
    local l = vim.api.nvim_win_get_cursor(win)[1]
    local item = items[l - 1]
    return item and item.value or nil
  end

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if M._picker_buf == buf then
      M._picker_buf = nil
    end
  end

  local function finish(value)
    selected = true
    close()
    if value ~= nil and opts.on_select then
      vim.schedule(function() opts.on_select(value) end)
    end
  end

  local function cancel()
    close()
    if opts.on_cancel then
      vim.schedule(opts.on_cancel)
    end
  end

  local function preview()
    local v = current_value()
    if v and opts.on_preview then opts.on_preview(v) end
  end

  local function move(delta)
    if not vim.api.nvim_win_is_valid(win) then return end
    local l = vim.api.nvim_win_get_cursor(win)[1]
    l = math.max(2, math.min(#items + 1, l + delta))
    vim.api.nvim_win_set_cursor(win, { l, 0 })
    preview()
  end

  local ko = { noremap = true, silent = true, nowait = true, buffer = buf }
  vim.keymap.set('n', 'j', function() move(1) end, ko)
  vim.keymap.set('n', 'k', function() move(-1) end, ko)
  vim.keymap.set('n', '<Down>', function() move(1) end, ko)
  vim.keymap.set('n', '<Up>', function() move(-1) end, ko)
  vim.keymap.set('n', '<C-j>', function() move(1) end, ko)
  vim.keymap.set('n', '<C-k>', function() move(-1) end, ko)
  vim.keymap.set('n', '<Esc>', cancel, ko)
  vim.keymap.set('n', 'q', cancel, ko)
  vim.keymap.set('n', '<CR>', function() finish(current_value()) end, ko)

  -- Safety net: if the buffer is wiped some other way (e.g. :qa), run cancel.
  vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufUnload' }, {
    buffer = buf,
    once = true,
    callback = function()
      if not selected then
        selected = true
        if M._picker_buf == buf then M._picker_buf = nil end
        if opts.on_cancel then vim.schedule(opts.on_cancel) end
      end
    end,
  })
end

M._open_picker = open_picker -- exposed for tests

-- ── public API ──────────────────────────────────────────────────────

function M.select()
  local entries = style_entries()
  local cur = theme.current()
  local persisted_style = tonumber(persist.get('theme_style', cur.style)) or cur.style
  local persisted_mode = persist.get('theme_mode', cur.mode)

  local items = {}
  for _, e in ipairs(entries) do
    local marker = (e.idx == cur.style) and '* ' or '  '
    items[#items + 1] = {
      display = string.format('%sStyle %-2d  %-14s %s', marker, e.idx, e.name, e.tagline),
      value = e.idx,
    }
  end

  open_picker(items, {
    title = 'wnvim · Style (1-' .. #entries .. ')',
    footer = '<CR> next step   <Esc> cancel   j/k navigate',
    on_preview = function(style_idx)
      theme.apply(style_idx, theme.current().mode, { persist = false })
    end,
    on_cancel = function()
      theme.apply(persisted_style, persisted_mode, { persist = false })
    end,
    on_select = function(style_idx)
      local mode_items = {
        { display = 'Day    - light background', value = 'day' },
        { display = 'Night  - dark background', value = 'night' },
      }
      open_picker(mode_items, {
        title = 'wnvim · ' .. theme.styles()[style_idx].name .. ' - Day or Night?',
        footer = '<CR> apply   <Esc> cancel',
        on_preview = function(mode)
          theme.apply(style_idx, mode, { persist = false })
        end,
        on_cancel = function()
          theme.apply(persisted_style, persisted_mode, { persist = false })
        end,
        on_select = function(mode)
          theme.apply(style_idx, mode)
          utils.notify(string.format(
            'Theme set: Style %d (%s) - %s. Saved.',
            style_idx, theme.styles()[style_idx].name, mode
          ))
        end,
      })
    end,
  })
end

function M.set_day()
  theme.set_mode('day')
  utils.notify('Day mode.')
end

function M.set_night()
  theme.set_mode('night')
  utils.notify('Night mode.')
end

return M
