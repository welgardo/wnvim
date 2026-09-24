--[[
Lazy telescope wrappers for keymap specs.

lazy.nvim evaluates `keys` tables at startup, so the mapped function
must exist immediately — but we must NOT `require('telescope.builtin')`
then (it would defeat lazy-loading). These thin closures require the
builtin *inside* the call, which also triggers telescope's own loading.
]]

local function wrap(fn_name)
  return function(...)
    require('telescope.builtin')[fn_name](...)
  end
end

return {
  find_files = wrap('find_files'),
  live_grep = wrap('live_grep'),
  buffers = wrap('buffers'),
  help_tags = wrap('help_tags'),
  keymaps = wrap('keymaps'),
  commands = wrap('commands'),
  oldfiles = wrap('oldfiles'),
  current_buffer_fuzzy_find = wrap('current_buffer_fuzzy_find'),
  lsp_document_diagnostics = wrap('lsp_document_diagnostics'),
  lsp_dynamic_workspace_symbols = wrap('lsp_dynamic_workspace_symbols'),
  git_commits = wrap('git_commits'),
  git_status = wrap('git_status'),
}
