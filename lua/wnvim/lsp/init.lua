--[[
LSP core: shared on_attach, capabilities, and server registration.

Servers are configured through nvim-lspconfig; Mason (see plugins/specs/lsp.lua)
installs the actual binaries. This module is intentionally data-driven so
adding a language = adding one entry to `servers.lua`.
]]

local M = {}

--- Shared keymaps/autocmds attached to every LSP buffer.
function M.on_attach(ev)
  local bufnr = ev.buf

  local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  map('gd', vim.lsp.buf.definition, 'definition')
  map('gD', vim.lsp.buf.declaration, 'declaration')
  map('gi', vim.lsp.buf.implementation, 'implementation')
  map('<leader>rn', vim.lsp.buf.rename, 'rename symbol')
  map('<leader>ca', vim.lsp.buf.code_action, 'code action')
  map('K', vim.lsp.buf.hover, 'hover docs')
  map('<leader>lf', vim.lsp.buf.format, 'format buffer')

  -- type_definition exists on all supported versions; guard anyway.
  if vim.lsp.buf.type_definition then
    map('gr', vim.lsp.buf.type_definition, 'type definition')
  end

  -- Telescope-backed pickers only when telescope is actually installed.
  local ok_tele = pcall(require, 'telescope.builtin')
  if ok_tele then
    map('<leader>ds', function()
      require('telescope.builtin').lsp_document_diagnostics()
    end, 'document diagnostics (telescope)')
    map('<leader>ws', function()
      require('telescope.builtin').lsp_dynamic_workspace_symbols()
    end, 'workspace symbols (telescope)')
  else
    map('<leader>ds', vim.diagnostic.setloclist, 'document diagnostics (loclist)')
  end

  -- Signature help while typing
  vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end,
    { buffer = bufnr, desc = 'LSP: signature help' })

  -- Inlay hints when supported (Neovim >= 0.10 has them built-in).
  local supports_inlay = false
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.server_capabilities.inlayHintProvider then supports_inlay = true end
  end
  if supports_inlay and vim.lsp.inlay_hint.enable then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

--- Extra capabilities merged with cmp's (set by the cmp spec at load time).
function M.capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok then
    caps = vim.tbl_deep_extend('force', caps, cmp_nvim_lsp.default_capabilities())
  end
  caps.textDocument = caps.textDocument or {}
  caps.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  return caps
end

--- Configure + start a single server by name with wnvim defaults.
function M.enable(server_name, overrides)
  -- NOTE: require('lspconfig') is deprecated in nvim-lspconfig v2 and will be
  -- removed in v3; the supported module path is 'lspconfig.configs'.
  local ok, configs = pcall(require, 'lspconfig.configs')
  if not ok then
    return false
  end
  local provider = configs[server_name]
  if not provider then
    return false
  end
  local config = vim.tbl_deep_extend('force', {
    capabilities = M.capabilities(),
    flags = { debounce_text_changes = 150 },
  }, overrides or {})
  provider.setup(config)
  return true
end

return M
