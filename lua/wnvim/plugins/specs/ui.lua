--[[
Statusline: lualine, wired to the wnvim theme engine.

We do NOT use a third-party lualine theme; instead we build a custom
theme object from the live palette (see lua/wnvim/ui/statusline.lua),
and refresh it whenever `User WnvimThemeChanged` fires — so the bar
matches Style N day/night instantly.
]]

return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local sl = require('wnvim.ui.statusline')

      local function lualine_theme()
        local c = sl.colors()
        return {
          normal = {
            a = { bg = c.accent, fg = c.accent_fg, gui = 'bold' },
            b = { bg = c.bg, fg = c.fg },
            c = { bg = c.bg, fg = c.dim },
          },
          insert = { a = { bg = c.fg, fg = c.bg, gui = 'bold' } },
          visual = { a = { bg = c.dim, fg = c.bg, gui = 'bold' } },
          replace = { a = { bg = c.accent, fg = c.bg, gui = 'bold' } },
          command = { a = { bg = c.border, fg = c.fg, gui = 'bold' } },
          inactive = {
            a = { bg = c.bg, fg = c.dim },
            b = { bg = c.bg, fg = c.dim },
            c = { bg = c.bg, fg = c.dim },
          },
        }
      end

      require('lualine').setup({
        options = {
          theme = lualine_theme(),
          globalstatus = true,
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = { statusline = { 'neo-tree', 'starter', 'dashboard' } },
          refresh = { statusline = 100 },
        },
        sections = {
          lualine_a = { { sl.mode, padding = { left = 1, right = 1 } } },
          lualine_b = {
            { 'branch', icon = '' },
            { 'diff', symbols = { added = '+', modified = '~', removed = '-' } },
          },
          lualine_c = {
            { 'filename', path = 1, symbols = { modified = ' [+]', readonly = ' [ro]', unnamed = '[No Name]' } },
          },
          lualine_x = {
            { sl.diagnostics, color = {} },
            { 'filetype' },
          },
          lualine_y = { { 'progress' } },
          lualine_z = { { 'location', padding = { left = 1, right = 1 } } },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {
          lualine_a = {
            { function() return ' wnvim ' .. (vim.g.wnvim_version or '') end, color = {} },
          },
          lualine_c = {},
          lualine_z = {
            { sl.theme_label, color = {} },
          },
        },
      })

      -- Rebuild colors live when the theme changes.
      vim.api.nvim_create_autocmd('User', {
        pattern = 'WnvimThemeChanged',
        group = vim.api.nvim_create_augroup('wnvim_lualine_theme', { clear = true }),
        callback = function()
          pcall(function()
            require('lualine').setup({ options = { theme = lualine_theme() } })
          end)
        end,
      })
    end,
  },

}
