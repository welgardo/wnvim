--[[
User-facing commands:

  :WnvimTheme / :WnvimThemeSelect   interactive two-step style+mode picker
  :WnvimThemeDay                    switch current style to day mode
  :WnvimThemeNight                  switch current style to night mode
  :WnvimThemeNext / :WnvimThemePrev cycle styles (keep mode)
  :WnvimThemeSet {style} [day|night] set directly, e.g. :WnvimThemeSet 5 night
  :WnvimUpdate                      git-pull the config + Lazy sync + TS update
  :WnvimDoctor                      environment health report
]]

local theme = require('wnvim.themes')
local utils = require('wnvim.utils')

local M = {}

local function cmd(name, fn, opts)
  vim.api.nvim_create_user_command(name, fn, opts or {})
end

function M.setup()
  cmd('WnvimTheme', function() require('wnvim.ui.picker').select() end,
    { desc = 'wnvim: pick a style (1-10) and mode (day/night)' })
  cmd('WnvimThemeSelect', function() require('wnvim.ui.picker').select() end,
    { desc = 'wnvim: alias of :WnvimTheme' })

  cmd('WnvimThemeDay', function() require('wnvim.ui.picker').set_day() end,
    { desc = 'wnvim: switch to day mode' })
  cmd('WnvimThemeNight', function() require('wnvim.ui.picker').set_night() end,
    { desc = 'wnvim: switch to night mode' })

  cmd('WnvimThemeNext', function() theme.cycle(1) end, { desc = 'wnvim: next style' })
  cmd('WnvimThemePrev', function() theme.cycle(-1) end, { desc = 'wnvim: previous style' })

  cmd('WnvimThemeSet', function(o)
    local parts = vim.split(o.args, '%s+', { trimempty = true })
    local style = tonumber(parts[1])
    local mode = parts[2]
    if not style then
      utils.notify('Usage: :WnvimThemeSet {1-10} [day|night]', vim.log.levels.WARN)
      return
    end
    theme.apply(style, mode or (theme.current() and theme.current().mode) or 'night')
  end, { desc = 'wnvim: set style directly', nargs = '+', complete = 'customlist,v:lua.wnvim_complete_theme' })

  -- Tab-completion helper for :WnvimThemeSet
  _G.wnvim_complete_theme = function(arglead, _, _)
    local out = {}
    for i = 1, #theme.styles() do
      out[#out + 1] = tostring(i)
    end
    out[#out + 1] = 'day'
    out[#out + 1] = 'night'
    return vim.tbl_filter(function(s) return s:find('^' .. vim.pesc(arglead)) end, out)
  end

  cmd('WnvimUpdate', function() require('wnvim.ui.commands').update() end,
    { desc = 'wnvim: update config (git pull + Lazy sync + treesitter update)' })

  cmd('WnvimDoctor', function() require('wnvim.ui.commands').doctor() end,
    { desc = 'wnvim: print an environment health report' })
end

-- ── :WnvimUpdate ────────────────────────────────────────────────────

function M.update()
  local cfg_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h:h:h')
  -- Above resolves to <config>/lua/wnvim/ui/commands.lua -> <config>.
  -- Prefer the reliable method: directory containing init.lua on rtp.
  local rtp = vim.api.nvim_get_option_value('runtimepath', {})
  for _, p in ipairs(vim.split(rtp, ',')) do
    if vim.fn.filereadable(p .. '/init.lua') == 1 and vim.fn.isdirectory(p .. '/lua/wnvim') == 1 then
      cfg_dir = p
      break
    end
  end

  if vim.fn.isdirectory(cfg_dir .. '/.git') ~= 1 then
    utils.notify('Config at ' .. cfg_dir .. ' is not a git checkout; nothing to update.',
      vim.log.levels.WARN)
    return
  end

  utils.notify('Updating wnvim from ' .. cfg_dir .. ' ...')
  local ok_pull = os.execute(('git -C %q pull --ff-only'):format(cfg_dir))
  if ok_pull then
    utils.notify('Git pull done. Syncing plugins...')
  else
    utils.notify('git pull failed (offline or conflict?). Continuing with plugin sync only.',
      vim.log.levels.WARN)
  end

  local ok_lazy, lazy = pcall(require, 'lazy')
  if ok_lazy then
    lazy.restore({ wait = true })
    lazy.sync({ wait = true })
    lazy.update({ wait = true })
  end

  local ok_ts, ts = pcall(require, 'nvim-treesitter')
  if ok_ts and ts.update then
    pcall(ts.update, {})
  end

  utils.notify('Update complete.')
end

-- ── :WnvimDoctor ────────────────────────────────────────────────────

local function check(cmd_name, min_note)
  local found = vim.fn.executable(cmd_name) == 1
  return { name = cmd_name, ok = found, note = min_note }
end

function M.doctor()
  local lines = { '', '  wnvim doctor', '  ════════════', '' }

  local function add(fmt, ...)
    lines[#lines + 1] = string.format(fmt, ...)
  end

  add('  Neovim      %s', tostring(vim.version()))
  if vim.version().major == 0 and vim.version().minor < 9 then
    add('  !! Neovim >= 0.9 recommended; some features may misbehave.')
  end

  local t = theme.current()
  local st = theme.styles()[t.style]
  add('  Theme       Style %d (%s) - %s', t.style, st.name, t.mode)
  add('  State file  %s', require('wnvim.utils.persist').file())
  add('  Config dir  %s', vim.fn.stdpath('config'))
  add('  Data dir    %s', vim.fn.stdpath('data'))
  add('')

  local checks = {
    check('git', 'required by lazy.nvim'),
    check('curl', 'used by installer'),
    check('tar', 'used by lazy bootstrap'),
    check('rg', 'Telescope live_grep (optional)'),
    check('fd', 'Telescope file finder (optional)'),
    check('fzf', 'installer fuzzy selection (optional)'),
    check('node', 'many language servers (recommended)'),
    check('npm', 'mason package installs (recommended)'),
    check('python3', 'LSP tooling fallback (optional)'),
  }
  for _, c in ipairs(checks) do
    add('  %s %-8s %s', c.ok and '[ok]' or '[--]', c.name, c.note or '')
  end

  add('')
  local ok_lazy = pcall(require, 'lazy')
  add('  lazy.nvim   %s', ok_lazy and 'installed' or 'NOT installed yet (will self-install)')
  local ok_mason = pcall(require, 'mason')
  add('  mason.nvim  %s', ok_mason and 'installed' or 'not loaded yet (lazy)')
  local ok_ts = pcall(require, 'nvim-treesitter')
  add('  treesitter  %s', ok_ts and 'installed' or 'not loaded yet (lazy)')

  add('')
  add('  Highlights  %d groups applied', vim.tbl_count(theme.build_highlights(t.style, t.mode)))
  add('')

  -- Show in a scratch buffer for readability.
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'wnvimdoctor'
  local aug = vim.api.nvim_create_augroup('wnvim_doctor', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinClosed' }, {
    group = aug, buffer = buf, once = true,
    callback = function()
      for _, w in ipairs(vim.fn.win_findbuf(buf)) do
        pcall(vim.api.nvim_win_close, w, true)
      end
    end,
  })
  vim.keymap.set('n', 'q', '<cmd>bdelete<cr>', { buffer = buf, silent = true })
  vim.cmd('vsplit | buffer ' .. buf)
  utils.notify('Doctor report ready (right split).')
end

return M
