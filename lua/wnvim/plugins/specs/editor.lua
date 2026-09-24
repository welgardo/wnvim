--[[
Editor plugins: explorer, fuzzy finder, keymap help, git integration.

All MIT-licensed upstream projects. Each spec is lazy-loaded via `keys`
or `event` to keep startup fast.
]]

local _tele = require('wnvim.plugins.specs._tele')

return {
  -- ── File explorer: neo-tree ───────────────────────────────────────
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = { 'Neotree' },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'File explorer (toggle)' },
      { '<leader>o', '<cmd>Neotree focus<cr>', desc = 'File explorer (focus)' },
    },
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' },
    opts = {
      close_if_last_window = true,
      popup_border_style = 'rounded',
      enable_git_status = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          never_ignore = { '.env.example' },
        },
      },
      window = {
        mappings = {
          ['<space>'] = 'none',
          ['h'] = 'close_node',
          ['l'] = 'open_node',
        },
      },
    },
  },

  -- ── Icons (used by neo-tree, telescope, lualine) ─────────────────
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- ── Utility library (dependency of several plugins) ──────────────
  { 'nvim-lua/plenary.nvim', lazy = true },

  -- ── Fuzzy finder: telescope ───────────────────────────────────────
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', _tele.find_files, desc = 'Find files' },
      { '<leader>fg', _tele.live_grep, desc = 'Live grep' },
      { '<leader>fb', _tele.buffers, desc = 'Buffers' },
      { '<leader>fh', _tele.help_tags, desc = 'Help tags' },
      { '<leader>fk', _tele.keymaps, desc = 'Keymaps' },
      { '<leader>fc', _tele.commands, desc = 'Commands' },
      { '<leader>fr', _tele.oldfiles, desc = 'Recent files' },
      { '<leader>/', _tele.current_buffer_fuzzy_find, desc = 'Search in buffer' },
      { '<leader>th', require('wnvim.ui.picker').select, desc = 'Theme selector' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          layout_strategy = 'flex',
          layout_config = { mirror = false },
          sorting_strategy = 'ascending',
          prompt_prefix = '> ',
          selection_caret = '* ',
          file_ignore_patterns = { '^%.git/', 'node_modules', '__pycache__', '%.lock$' },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      -- fzf-native sorter (installed conditionally by the spec below):
      -- load via pcall so a missing compiled extension never breaks
      -- telescope startup.
      pcall(require('telescope').load_extension, 'fzf')
    end,
  },

  -- Faster sorter for telescope (optional C extension; skipped if no cc).
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    lazy = true,
    cond = function()
      return vim.fn.executable('make') == 1 and vim.fn.executable('cc') == 1
    end,
  },

  -- ── Keymap help: which-key ────────────────────────────────────────
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      icons = { breadcrumb = '>', separator = '-' },
      win = { border = 'rounded', padding = { 1, 2 } },
      -- NOTE: `spec` entries are parsed with which-key's current (v2) list
      -- spec format. The previous `{ g = { name = 'goto' } }` entry used the
      -- old v1 dict syntax and produced a startup error notification
      -- ("Invalid field `g`", FINAL QA blocker). All groups below use the
      -- supported form; no mappings were removed, only reformatted.
      spec = {
        { '<leader>', group = 'wnvim' },
        { '<leader>f', group = 'find' },
        { '<leader>b', group = 'buffer' },
        { '<leader>g', group = 'git' },
        { '<leader>l', group = 'lsp' },
        { '<leader>d', group = 'diagnostics' },
        { '<leader>t', group = 'theme/test' },
        { '<leader>c', group = 'code/close' },
        { '<leader>s', group = 'split/session' },
        { '<leader>q', group = 'quit' },
        { 'g', group = 'goto' },
        { '[', group = 'prev' },
        { ']', group = 'next' },
      },
    },
  },

  -- ── Git integration: gitsigns ─────────────────────────────────────
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '^' },
        changedelete = { text = '!' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local map = function(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = 'Git: ' .. desc })
        end
        map(']c', function() gs.nav_hunk('next') end, 'Next hunk')
        map('[c', function() gs.nav_hunk('prev') end, 'Prev hunk')
        map('<leader>gh', gs.preview_hunk, 'Preview hunk')
        map('<leader>gs', gs.stage_hunk, 'Stage hunk')
        map('<leader>gr', gs.reset_hunk, 'Reset hunk')
        map('<leader>gp', gs.prev_hunk, 'Hunk previous')
        map('<leader>gn', gs.next_hunk, 'Hunk next')
        map('<leader>gS', gs.stage_buffer, 'Stage buffer')
        map('<leader>gB', gs.blame_line, 'Blame line')
        map('<leader>gd', gs.diffthis, 'Diff against index')
        map('<leader>gq', gs.setqflist, 'All hunks to quickfix')
      end,
    },
  },

  -- ── Indent guides (pure-lua, no deps) ─────────────────────────────
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = 'VeryLazy',
    opts = {
      indent = { char = '┆' },
      scope = { enabled = false },
      exclude = { filetypes = { 'neo-tree', 'TelescopePrompt', 'terminal' } },
    },
  },

  -- ── Smooth scroll & nice-to-haves kept minimal on purpose ────────
  {
    'echasnovski/mini.bufremove',
    keys = {
      { '<leader>bd', function() require('mini.bufremove').delete() end, desc = 'Delete buffer (no close)' },
    },
    config = true,
  },
}
