--[[
Formatting & external diagnostics via none-ls (nvim-null-ls).

Design goals:
  * works on any Linux distro — every source is registered ONLY when its
    underlying binary actually exists at startup (`vim.fn.executable`),
    so missing tools are silently inactive instead of erroring;
  * nothing hardcoded to one machine — Mason-installed executables land
    in <data>/mason/bin, which the Mason plugin spec prepends to $PATH
    before this module runs;
  * uses official none-ls builtins (maintained upstream) rather than
    hand-rolled generators.

Public API:
  M.setup()        called from the none-ls plugin spec on load
  M.format_sync()  best-effort format of the current buffer
]]

local M = {}

local function has_bin(name)
  return vim.fn.executable(name) == 1
end

-- none-ls builtin name -> executable that must exist
local FORMATTERS = {
  black = 'black',
  stylua = 'stylua',
  shfmt = 'shfmt',
  prettier_d = 'prettierd',
  prettier = 'prettier',
  gofmt = 'gofmt',
  rustfmt = 'rustfmt',
  clangformat = 'clang-format',
  jq = 'jq',
}

local DIAGNOSTICS = {
  shellcheck = 'shellcheck',
  luacheck = 'luacheck',
  pylint = 'pylint',
  flake8 = 'flake8',
  eslint_d = 'eslint_d',
  eslint = 'eslint',
  markdownlint = 'markdownlint',
  codespell = 'codespell',
}

function M.setup()
  local ok, nls = pcall(require, 'none-ls')
  if not ok then return end
  local ok_b, b = pcall(require, 'none-ls.builtins')
  if not ok_b then return end

  local sources = {}

  for src_name, exe in pairs(FORMATTERS) do
    local src = b.formatting and b.formatting[src_name]
    -- Avoid registering both prettier variants.
    if src_name == 'prettier' and has_bin('prettierd') then src = nil end
    if src and has_bin(exe) then
      sources[#sources + 1] = src
    end
  end

  for src_name, exe in pairs(DIAGNOSTICS) do
    local src = b.diagnostics and b.diagnostics[src_name]
    if src_name == 'eslint' and has_bin('eslint_d') then src = nil end
    if src and has_bin(exe) then
      sources[#sources + 1] = src
    end
  end

  nls.setup({
    sources = sources,
    update_in_insert = false,
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = true
      _ = bufnr
    end,
  })
end

--- Format the current buffer via attached LSP formatters.
--- Best-effort: warns when no client can format instead of failing silently.
function M.format_sync()
  local clients = vim.lsp.get_clients and vim.lsp.get_clients({ bufnr = 0 })
      or vim.lsp.buf_get_clients(0)
  if #clients == 0 then
    require('wnvim.utils').notify('No LSP/formatter attached to this buffer.', vim.log.levels.WARN)
    return
  end
  vim.lsp.buf.format({ timeout_ms = 2500 })
end

return M
