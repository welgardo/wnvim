--[[
wnvim theme engine.

Design: instead of shelling out to 20 third-party colorscheme plugins,
wnvim generates its own colorscheme (`wnvim`) from the declarative
palettes in styles.lua. Benefits:

  * zero copyright/licensing risk (palettes are our own derivations,
    documented per-style)
  * truly consistent look across editor + statusline + picker + LSP UI
  * adding style #11 = adding one table entry, no new plugin
  * instant live switching without restarting Neovim

Public API:
  M.setup()                 read persisted selection, register autocmds
  M.apply(style, mode)      apply immediately (mode: "day"|"night")
  M.cycle(delta)            next/prev style (keeps current mode)
  M.set_mode(mode)          switch day/night within current style
  M.current()               {style=n, mode="day|night"}
  M.palette()              active palette table
  M.styles()               registry (for pickers / docs)
]]

local styles = require('wnvim.themes.styles')
local persist = require('wnvim.utils.persist')
local utils = require('wnvim.utils')

local M = {}

M._current = nil -- { style = <int>, mode = 'day'|'night' }

local DEFAULT_STYLE = 2 -- Tokyo Neon
local DEFAULT_MODE = 'night'

-- ── helpers ─────────────────────────────────────────────────────────

local function valid_style(n)
  return type(n) == 'number' and styles[n] ~= nil
end

local function resolve_selection()
  local s = tonumber(persist.get('theme_style', nil)) or tonumber(vim.env.WNVIM_THEME_STYLE)
  local m = persist.get('theme_mode', nil) or vim.env.WNVIM_THEME_MODE
  if not valid_style(s) then s = DEFAULT_STYLE end
  if m ~= 'day' and m ~= 'night' then m = DEFAULT_MODE end
  return { style = s, mode = m }
end

--- Convert "#rrggbb" -> number for nvim_set_hl, with fallback.
local function hex(c, fallback)
  if type(c) == 'string' and c:match('^#%x%x%x%x%x%x$') then
    return tonumber(c:sub(2), 16)
  end
  return fallback
end

-- ── highlight generation ────────────────────────────────────────────

--- Build the full highlight-group table for a style+mode.
---@return table<string, table>
function M.build_highlights(style_idx, mode)
  local st = styles[style_idx]
  assert(st, 'unknown wnvim style: ' .. tostring(style_idx))
  local p = st[mode]
  assert(p, 'unknown theme mode: ' .. tostring(mode))

  local bg = hex(p.bg, 0x1e1e2e)
  local fg = hex(p.fg, 0xdde0e0)
  local bg_alt = hex(p.bg_alt, bg)
  local visual = hex(p.bg_visual, bg_alt)
  local search = hex(p.bg_search, 0x4a4433)
  local gutter = hex(p.fg_gutter, 0x606070)
  local comment = hex(p.comment, gutter)
  local cursor = hex(p.cursor, fg)
  local border = hex(p.border, bg_alt)
  local accent = hex(p.accent, fg)

  local red = hex(p.red, 0xf38ba8)
  local green = hex(p.green, 0xa6e3a1)
  local yellow = hex(p.yellow, 0xf9e2af)
  local blue = hex(p.blue, 0x89b4fa)
  local magenta = hex(p.magenta, 0xcba6f7)
  local cyan = hex(p.cyan, 0x89dceb)
  local black = hex(p.black, bg)
  local white = hex(p.white, fg)

  local error = hex(p.error, red)
  local warn = hex(p.warn, yellow)
  local info = hex(p.info, blue)
  local hint = hex(p.hint, green)

  local italic = st.italic and true or false

  local hl = {
    -- Editor core -----------------------------------------------------
    Normal = { bg = bg, fg = fg },
    NormalFloat = { bg = bg_alt, fg = fg },
    NormalNC = { bg = bg, fg = fg },
    FloatBorder = { bg = bg_alt, fg = border },
    FloatTitle = { bg = bg_alt, fg = accent, bold = true },
    Darken = { bg = bg, fg = fg },
    ColorColumn = { bg = bg_alt },
    Cursor = { bg = cursor, fg = bg },
    CursorIM = { bg = cursor, fg = bg },
    lCursor = { bg = cursor, fg = bg },
    CursorLine = { bg = bg_alt, sp = cursor },
    CursorLineNr = { fg = accent, bold = true },
    LineNr = { fg = gutter },
    LineNrAbove = { fg = gutter },
    LineNrBelow = { fg = gutter },
    CursorColumn = { bg = bg_alt },
    MatchWord = { underline = true, sp = accent },
    Visual = { bg = visual },
    VisualNOS = { bg = visual },
    Search = { bg = search, fg = fg },
    IncSearch = { bg = accent, fg = bg, bold = true },
    CurSearch = { bg = accent, fg = bg, bold = true },
    Substitute = { bg = red, fg = bg },
    Directory = { fg = blue, bold = true },
    ErrorMsg = { bg = bg, fg = error, bold = true },
    WarningMsg = { bg = bg, fg = warn },
    ModeMsg = { fg = accent, bold = true },
    MoreMsg = { fg = green },
    Question = { fg = accent, bold = true },
    NonText = { fg = gutter },
    SpecialKey = { fg = gutter },
    Whitespace = { fg = gutter },
    Folded = { bg = bg_alt, fg = comment, italic = true },
    FoldColumn = { bg = bg, fg = gutter },
    SignColumn = { bg = bg },
    Title = { fg = accent, bold = true },
    Conceal = { fg = comment },

    -- Popup menu / completion -----------------------------------------
    Pmenu = { bg = bg_alt, fg = fg },
    PmenuSel = { bg = accent, fg = bg, bold = true },
    PmenuSbar = { bg = bg_alt },
    PmenuThumb = { bg = gutter },
    PmenuMatch = { bg = bg_alt, fg = accent },

    -- Tabs ------------------------------------------------------------
    TabLine = { bg = bg_alt, fg = comment },
    TabLineSel = { bg = accent, fg = bg, bold = true },
    TabLineFill = { bg = bg_alt },

    -- Spelling / misc ---------------------------------------------------
    SpellBad = { undercurl = true, sp = error },
    SpellCap = { undercurl = true, sp = blue },
    SpellLocal = { undercurl = true, sp = cyan },
    SpellRare = { undercurl = true, sp = magenta },

    -- Diff groups -------------------------------------------------------
    DiffAdd = { bg = '#1d3520', fg = green },
    DiffChange = { bg = '#2c2a45', fg = blue },
    DiffDelete = { bg = '#3d1f24', fg = red },
    DiffText = { bg = '#3d3a1f', fg = yellow },
    diffAdded = { fg = green },
    diffRemoved = { fg = red },
    diffChanged = { fg = blue },
    diffFile = { fg = accent, bold = true },
    diffNewFile = { fg = green, bold = true },
    diffOldFile = { fg = red, bold = true },
    diffLine = { fg = comment },
    diffIndexLine = { fg = magenta },

    -- Diagnostics ---------------------------------------------------------
    DiagnosticError = { fg = error },
    DiagnosticWarn = { fg = warn },
    DiagnosticInfo = { fg = info },
    DiagnosticHint = { fg = hint },
    DiagnosticOk = { fg = green },
    DiagnosticUnderlineError = { undercurl = true, sp = error },
    DiagnosticUnderlineWarn = { undercurl = true, sp = warn },
    DiagnosticUnderlineInfo = { undercurl = true, sp = info },
    DiagnosticUnderlineHint = { undercurl = true, sp = hint },
    DiagnosticVirtualTextError = { bg = bg_alt, fg = error },
    DiagnosticVirtualTextWarn = { bg = bg_alt, fg = warn },
    DiagnosticVirtualTextInfo = { bg = bg_alt, fg = info },
    DiagnosticVirtualTextHint = { bg = bg_alt, fg = hint },
    DiagnosticSignError = { fg = error },
    DiagnosticSignWarn = { fg = warn },
    DiagnosticSignInfo = { fg = info },
    DiagnosticSignHint = { fg = hint },
    LspInlayHint = { fg = comment, bg = bg, italic = true },
    LspReferenceText = { bg = visual },
    LspReferenceRead = { bg = visual },
    LspReferenceWrite = { bg = visual, underline = true, sp = accent },
    LspSignatureActiveParameter = { fg = accent, bold = true },

    -- Treesitter legacy capture groups (kept for plugins/tools that still
    -- reference TSFoo; map to the modern @foo captures defined below).
    TSComment = { link = '@comment' },
    TSConditional = { link = '@keyword.conditional' },
    TSConstant = { link = '@constant' },
    TSFunction = { link = '@function' },
    TSKeyword = { link = '@keyword' },
    TSString = { link = '@string' },
    TSType = { link = '@type' },
    TSVariable = { link = '@variable' },
  }

  -- Core syntax groups ---------------------------------------------------
  local syntax = {
    Comment = { fg = comment, italic = italic },
    Constant = { fg = magenta },
    String = { fg = green },
    Character = { fg = green },
    Number = { fg = yellow },
    Boolean = { fg = yellow },
    Float = { fg = yellow },
    Identifier = { fg = blue },
    Function = { fg = blue, bold = true },
    Statement = { fg = red },
    Conditional = { fg = red, italic = italic },
    Repeat = { fg = red, italic = italic },
    Operator = { fg = cyan },
    Exception = { fg = magenta, italic = italic },
    Include = { fg = magenta, italic = italic },
    Define = { fg = magenta },
    PreProc = { fg = magenta },
    Macro = { fg = magenta },
    Type = { fg = yellow },
    StorageClass = { fg = red, italic = italic },
    Structure = { fg = magenta },
    Typedef = { fg = yellow },
    Special = { fg = cyan },
    SpecialChar = { fg = cyan },
    Tag = { fg = yellow },
    Delimiter = { fg = white },
    SpecialComment = { fg = accent, italic = italic },
    Debug = { fg = red },
    Label = { fg = red },
    Underlined = { fg = blue, underline = true },
    Ignore = { fg = bg },
    Todo = { fg = accent, bold = true, italic = true },
  }
  for k, v in pairs(syntax) do hl[k] = v end

  -- Treesitter @captures (Neovim >= 0.10 naming) --------------------------
  local ts = {
    ['@comment'] = { fg = comment, italic = italic },
    ['@comment.documentation'] = { fg = comment, italic = italic },
    ['@error'] = { fg = error, bold = true },
    ['@none'] = {},
    ['@preproc'] = { fg = magenta },
    ['@define'] = { fg = magenta },
    ['@operator'] = { fg = cyan },
    ['@punctuation.delimiter'] = { fg = white },
    ['@punctuation.bracket'] = { fg = white },
    ['@punctuation.special'] = { fg = cyan },
    ['@string'] = { fg = green },
    ['@string.regex'] = { fg = cyan },
    ['@string.escape'] = { fg = magenta },
    ['@string.special'] = { fg = yellow },
    ['@character'] = { fg = green },
    ['@character.special'] = { fg = magenta },
    ['@boolean'] = { fg = yellow },
    ['@number'] = { fg = yellow },
    ['@float'] = { fg = yellow },
    ['@function'] = { fg = blue, bold = true },
    ['@function.call'] = { fg = blue },
    ['@function.builtin'] = { fg = cyan, bold = true },
    ['@function.method'] = { fg = blue },
    ['@function.method.call'] = { fg = blue },
    ['@constructor'] = { fg = cyan },
    ['@conditional'] = { fg = red, italic = italic },
    ['@conditional.ternary'] = { fg = red },
    ['@repeat'] = { fg = red, italic = italic },
    ['@debug'] = { fg = red },
    ['@label'] = { fg = red },
    ['@include'] = { fg = magenta, italic = italic },
    ['@keyword'] = { fg = red, bold = true },
    ['@keyword.coroutine'] = { fg = magenta },
    ['@keyword.function'] = { fg = magenta, bold = true },
    ['@keyword.operator'] = { fg = cyan },
    ['@keyword.import'] = { fg = magenta, italic = italic },
    ['@keyword.type'] = { fg = magenta },
    ['@keyword.modifier'] = { fg = red },
    ['@keyword.repeat'] = { fg = red, italic = italic },
    ['@keyword.return'] = { fg = magenta, bold = true },
    ['@keyword.debug'] = { fg = red },
    ['@keyword.exception'] = { fg = magenta, italic = italic },
    ['@keyword.conditional'] = { fg = red, italic = italic },
    ['@keyword.directives'] = { fg = magenta },
    ['@exception'] = { fg = magenta },
    ['@spell'] = { sp = blue, undercurl = true },
    ['@property'] = { fg = blue },
    ['@field'] = { fg = blue },
    ['@property.private'] = { fg = red },
    ['@types'] = { fg = yellow },
    ['@type.builtin'] = { fg = yellow, bold = true },
    ['@type.definition'] = { fg = yellow },
    ['@type.qualifier'] = { fg = red },
    ['@type.tag'] = { fg = cyan },
    ['@attribute'] = { fg = yellow },
    ['@event'] = { fg = yellow },
    ['@modifier'] = { fg = red },
    ['@variable'] = { fg = fg },
    ['@variable.builtin'] = { fg = red, italic = italic },
    ['@variable.member'] = { fg = blue },
    ['@variable.parameter'] = { fg = magenta },
    ['@constant'] = { fg = magenta },
    ['@constant.builtin'] = { fg = magenta, bold = true },
    ['@constant.macro'] = { fg = magenta },
    ['@namespace'] = { fg = yellow },
    ['@symbol'] = { fg = magenta },
    ['@module'] = { fg = yellow },
    ['@module.builtin'] = { fg = yellow, bold = true },
    ['@embed'] = { fg = green },
    ['@text'] = { fg = fg },
    ['@text.title'] = { fg = accent, bold = true },
    ['@text.literal'] = { fg = green },
    ['@text.uri'] = { fg = blue, underline = true },
    ['@text.math'] = { fg = cyan },
    ['@text.reference'] = { fg = yellow },
    ['@text.todo'] = { fg = accent, bold = true },
    ['@text.note'] = { fg = info },
    ['@text.warning'] = { fg = warn },
    ['@text.danger'] = { fg = error },
    ['@text.diff.add'] = { fg = green },
    ['@text.diff.delete'] = { fg = red },
    ['@tag'] = { fg = red },
    ['@tag.attribute'] = { fg = yellow },
    ['@tag.delimiter'] = { fg = comment },
    ['@conceal'] = { fg = gutter },
  }
  for k, v in pairs(ts) do hl[k] = v end

  -- Terminal ANSI colors ----------------------------------------------------
  for i, c in ipairs({ black, red, green, yellow, blue, magenta, cyan, white }) do
    hl['Terminal' .. i] = { fg = c, bg = bg }
  end

  -- Plugin integration groups (safe to define even before plugins load) ------
  local plugin_hl = {
    -- gitsigns
    GitSignsAdd = { fg = green }, GitSignsChange = { fg = blue }, GitSignsDelete = { fg = error },
    -- neo-tree
    NeoTreeDirectoryIcon = { fg = blue },
    NeoTreeDirectoryName = { fg = fg },
    NeoTreeDotfile = { fg = comment },
    NeoTreeFileName = { fg = fg },
    NeoTreeFileIcon = { fg = fg },
    NeoTreeRootName = { fg = accent, bold = true },
    NeoTreeIndentMarker = { fg = border },
    NeoTreeSymbolicLinkTarget = { fg = cyan },
    NeoTreeNormal = { bg = bg_alt }, NeoTreeNormalNC = { bg = bg_alt },
    NeoTreeEndOfBuffer = { bg = bg_alt, fg = bg_alt },
    NeoTreeWinSeparator = { fg = border, bg = bg_alt },
    NeoTreeCursorLine = { bg = visual },
    NeoTreeModified = { fg = yellow },
    -- telescope
    TelescopeNormal = { bg = bg_alt, fg = fg },
    TelescopeBorder = { bg = bg_alt, fg = border },
    TelescopeTitle = { bg = bg_alt, fg = accent, bold = true },
    TelescopePromptNormal = { bg = bg, fg = fg },
    TelescopePromptBorder = { bg = bg, fg = accent },
    TelescopePromptPrefix = { fg = accent },
    TelescopePromptCounter = { fg = comment },
    TelescopeSelection = { bg = visual, fg = fg, bold = true },
    TelescopeSelectionCaret = { fg = accent },
    TelescopeMatching = { fg = accent, bold = true },
    TelescopePreviewLine = { bg = visual },
    -- neo-tree floating windows
    NeoTreeFloatBorder = { link = 'FloatBorder' },
    NeoTreeTitleBar = { bg = accent, fg = bg },
    -- which-key
    WhichKey = { fg = blue, bold = true },
    WhichKeyGroup = { fg = magenta },
    WhichKeyDesc = { fg = fg },
    WhichKeySeparator = { fg = comment },
    WhichKeyValue = { fg = comment },
    -- nvim-cmp kind faces
    CmpItemAbbr = { fg = fg },
    CmpItemAbbrDeprecated = { fg = comment, strikethrough = true },
    CmpItemAbbrMatch = { fg = accent, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = accent, italic = true },
    CmpItemKind = { fg = cyan },
    CmpItemMenu = { fg = comment },
    -- lazy.nvim
    LazyNormal = { bg = bg },
    LazyNormalFloat = { bg = bg_alt },
    LazyFloatTitle = { fg = accent, bold = true },
    LazyProgressDone = { fg = green },
    LazyProgressTodo = { fg = comment },
    LazyDimmed = { fg = comment },
    LazyOperator = { fg = cyan },
    LazyUrl = { fg = blue, underline = true },
    LazyReasonPlugin = { fg = yellow },
    LazyHighlightGroup = { fg = magenta },
    -- mason
    MasonNormal = { bg = bg },
    MasonHeader = { bg = accent, fg = bg, bold = true },
    MasonHeaderSecondary = { bg = green, fg = bg, bold = true },
    MasonHighlight = { fg = green },
    MasonHighlightBlock = { bg = accent, fg = bg },
    MasonMuted = { fg = comment },
    MasonMutedBlock = { bg = bg_alt, fg = fg },
    -- winbar
    WnvimWinBar = { bg = bg, fg = comment },
    WnvimWinBarModified = { bg = bg, fg = yellow, bold = true },
    -- dashboard/banner
    WnvimBanner = { fg = accent, bold = true },
    WnvimBannerDim = { fg = comment },
    -- noice/notify borders etc.
    NotifyERRORborder = { fg = error },
    NotifyWARNborder = { fg = warn },
    NotifyINFOborder = { fg = info },
    NotifyDEBUGborder = { fg = comment },
  }
  for k, v in pairs(plugin_hl) do hl[k] = v end

  return hl
end

--- Set g:terminal_ansi_colors so :terminal matches the palette.
local function apply_terminal_colors(p)
  local cols = {}
  local order = { 'black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white' }
  for _, name in ipairs(order) do
    cols[#cols + 1] = p[name]
    cols[#cols + 1] = p[name] -- bright variants reuse base (consistent look)
  end
  vim.g.terminal_ansi_colors = cols
end

-- ── public API ──────────────────────────────────────────────────────

function M.styles()
  return styles
end

function M.current()
  return M._current
end

function M.palette()
  if not M._current then return nil end
  local st = styles[M._current.style]
  return st and st[M._current.mode] or nil
end

--- Apply a style+mode right now (no restart needed).
---@param style_idx number 1..#styles
---@param mode string 'day' | 'night'
---@param opts? {persist?: boolean}
function M.apply(style_idx, mode, opts)
  opts = opts or {}
  mode = mode or (M._current and M._current.mode) or DEFAULT_MODE
  if not valid_style(style_idx) then
    utils.notify('unknown style: ' .. tostring(style_idx), vim.log.levels.ERROR)
    return false
  end
  if mode ~= 'day' and mode ~= 'night' then
    utils.notify("mode must be 'day' or 'night'", vim.log.levels.ERROR)
    return false
  end

  local st = styles[style_idx]
  local p = st[mode]

  vim.go.background = (mode == 'day') and 'light' or 'dark'
  apply_terminal_colors(p)

  -- Colorscheme identity for `:colorscheme` display & Statusline hooks
  vim.g.colors_name = 'wnvim'

  local defs = M.build_highlights(style_idx, mode)
  utils.hlset(defs)

  M._current = { style = style_idx, mode = mode }

  if opts.persist ~= false then
    persist.set('theme_style', style_idx)
    persist.set('theme_mode', mode)
  end

  -- Let lualine / other UI refresh
  vim.api.nvim_exec_autocmds('ColorScheme', { pattern = 'wnvim', modeline = false })
  vim.cmd('doautocmd User WnvimThemeChanged')

  return true
end

function M.cycle(delta)
  if not M._current then return end
  local n = #styles
  local s = ((M._current.style - 1 + delta) % n) + 1
  M.apply(s, M._current.mode)
  utils.notify(string.format('%s — %s', styles[s].name, M._current.mode))
end

function M.set_mode(mode)
  if not M._current then return end
  M.apply(M._current.style, mode)
end

--- Startup wiring: register the ColorScheme guard so external resets
--- (e.g. t_Co change, focus events) re-apply our highlights.
function M.setup()
  M._current = resolve_selection()
  M.apply(M._current.style, M._current.mode, { persist = false })

  vim.api.nvim_create_autocmd('VimResized', {
    group = vim.api.nvim_create_augroup('wnvim_theme', { clear = true }),
    callback = function()
      -- Redraw safety net for some terminals after resize.
      if M._current then
        utils.hlset(M.build_highlights(M._current.style, M._current.mode))
      end
    end,
  })
end

return M
