--[[
Treesitter: fast, accurate syntax highlighting + textobjects.

Note on branches: the actively maintained upstream branch is `master`
(the `main` rewrite was merged back in 2025). We follow upstream and
pin lazy's default branch; `build = ':TSUpdate'` keeps parsers fresh.
The config below uses the classic module API (`nvim-treesitter.config`),
which every released version supports, with a defensive fallback if the
module layout ever changes again.

`ensure_installed` contains only parsers that build with nothing but a
C compiler (which Neovim itself requires anyway); anything else is left
to `auto_install` when you actually open such a file.
]]

return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false, -- highlighting must be ready immediately
    keys = {
      { '<leader>tS', function() require('telescope.builtin').treesitter() end, desc = 'Treesitter symbols' },
      { '<leader>tI', ':TSInstall ', desc = 'TS install parser (type name)' },
      { '<leader>tU', '<cmd>TSUpdate<cr>', desc = 'TS update parsers' },
    },
    config = function()
      -- Parsers we ship by default. All build with just a C compiler.
      local ensure_installed = {
        'bash', 'c', 'cpp', 'css', 'html', 'java', 'javascript', 'json',
        'lua', 'luadoc', 'markdown', 'markdown_inline', 'python', 'query',
        'regex', 'toml', 'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
      }

      -- Classic module API (all released nvim-treesitter versions).
      local ok_legacy, ts_config = pcall(require, 'nvim-treesitter.config')
      if ok_legacy and ts_config and ts_config.setup then
        ts_config.setup({
          ensure_installed = ensure_installed,
          sync_install = false,
          auto_install = true,
          highlight = { enable = true, additional_vim_regex_highlighting = false },
          indent = { enable = true },
        })
        return
      end

      -- Alternative top-level API (defensive: some rewrites expose it here).
      local ok_api, ts_main = pcall(require, 'nvim-treesitter')
      if ok_api and ts_main and ts_main.setup then
        ts_main.setup({
          highlight = { enable = true },
          install = { languages = ensure_installed },
        })
        return
      end

      vim.notify('[wnvim] nvim-treesitter API not recognised; run :Lazy Sync',
        vim.log.levels.WARN)
    end,
  },

  -- Textobject helpers (classic module API, same as core plugin).
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local ok, ts_config = pcall(require, 'nvim-treesitter.config')
      if not ok or not ts_config then return end
      pcall(ts_config.setup, {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
            goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          },
        },
      })
    end,
  },
}
