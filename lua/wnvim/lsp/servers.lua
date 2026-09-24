--[[
Default language servers enabled out of the box.

This list is deliberately small and cross-distro: each entry maps an
lspconfig server name -> a Mason package name that provides its binary.
Mason installs only what it can (missing prerequisites are skipped with
a warning, never fatal).

To add a language:
  1. add the pair here,
  2. (optional) add formatter setup in null_ls/sources.lua,
  3. run :WnvimUpdate / restart — no other file needs touching.
]]

return {
  lua_ls = 'lua-language-server',       -- Neovim/Lua development
  bashls = 'bash-language-server',      -- shell scripts
  pyright = 'pyright',                  -- Python
  marksman = 'marksman',                -- Markdown
  jsonls = 'vscode-langservers-extracted', -- JSON (also provides eslint/prettier via mason)
}
