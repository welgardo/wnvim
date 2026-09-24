--[[
Top-level lazy.nvim setup. Called from init.lua after core options.
]]

local bootstrap = require('wnvim.plugins')

if not bootstrap.bootstrap() then
  -- Without lazy.nvim we degrade gracefully: plain editor, theme still works.
  return
end

-- A minimal colorscheme name must exist for lazy's install step; our
-- theme engine already applied highlights directly, so tell lazy to
-- skip loading any colorscheme.
require('lazy').setup(bootstrap.collect_specs(), {
  install = { colorscheme = { 'default' } },
  checker = { enabled = false }, -- no background version nagging
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin',
      },
    },
  },
})
