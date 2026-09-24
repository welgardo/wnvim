--[[
LSP stack: Mason (tool installer), nvim-lspconfig, none-ls.

Loading strategy:
  * mason.nvim loads on :Mason / :MasonInstall commands;
  * lspconfig + servers load when Mason has finished its first setup OR
    at VeryLazy — whichever comes first — so language servers attach to
    real files without slowing startup;
  * the default server set lives in lua/wnvim/lsp/servers.lua (data-driven).
]]

local servers_map = require('wnvim.lsp.servers')

-- Build the Mason ensure_installed list from the same table that drives
-- lspconfig, so both stay in sync automatically.
local ensure = {}
for _, pkg in pairs(servers_map) do
  ensure[#ensure + 1] = pkg
end
-- Handy formatters/linters installable through Mason:
local extra_tools = { 'stylua', 'shellcheck', 'prettierd', 'shfmt' }
for _, t in ipairs(extra_tools) do
  ensure[#ensure + 1] = t
end

return {
  -- ── Mason: portable installer for LSP servers / tools ─────────────
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonLog', 'MasonUpdate' },
    build = ':MasonUpdate',
    opts = {
      ui = { border = 'rounded', icons = { package_pending = '>', package_installed = '*', package_uninstalled = '-' } },
    },
    config = function(_, opts)
      require('mason').setup(opts)
      -- Put Mason's bin dir on PATH so none-ls and shell tools find it.
      local bin = vim.fn.stdpath('data') .. '/mason/bin'
      if vim.fn.isdirectory(bin) == 1 then
        vim.env.PATH = bin .. ':' .. vim.env.PATH
      end
    end,
  },

  -- ── mason-lspconfig: bridge between mason packages & lspconfig ───
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    event = 'VeryLazy',
    opts = {
      ensure_installed = ensure,
      automatic_installation = false, -- we drive installation explicitly below
    },
    config = function(_, opts)
      local mlsp = require('mason-lspconfig')
      mlsp.setup(opts)

      local wnvim_lsp = require('wnvim.lsp')
      local registry_ok, registry = pcall(require, 'mason-registry')

      --- Enable an lspconfig server now.
      local function enable_now(server_name)
        wnvim_lsp.enable(server_name)
      end

      for server_name, package_name in pairs(servers_map) do
        local installed_locally = vim.fn.executable(package_name) == 1
        if not registry_ok then
          enable_now(server_name)
        else
          local ok_pkg, pkg = pcall(registry.get_package, package_name)
          if (not ok_pkg) or (not pkg) or pkg:is_installed() or installed_locally then
            enable_now(server_name)
          else
            -- Kick off a background install; enable when it succeeds.
            local ok_install, job = pcall(function() return pkg:install() end)
            if ok_install and job and job.once then
              job:once('closed', function(code)
                if code == 0 then
                  vim.schedule(function() enable_now(server_name) end)
                end
              end)
            end
          end
        end
      end

      -- Respect servers the user installed manually via :MasonInstall.
      local ok_handlers, err = pcall(mlsp.setup_handlers, {
        function(server_name)
          if not servers_map[server_name] then
            enable_now(server_name)
          end
        end,
      })
      _ = ok_handlers; _ = err
    end,
  },

  -- ── nvim-lspconfig: the actual client configs ─────────────────────
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
  },

  -- ── none-ls: formatters & external linters ────────────────────────
  {
    'nvimtools/none-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('wnvim.formatting').setup()
    end,
  },

  -- ── Extra LSP niceties ────────────────────────────────────────────
  {
    'folke/neodev.nvim',
    opts = { library = { plugins = { 'nvim-treesitter' }, types = true } },
    ft = 'lua',
  },
}
