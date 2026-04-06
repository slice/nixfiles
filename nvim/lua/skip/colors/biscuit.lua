-- vim: set fdm=marker:

local lush = require 'lush'
local H = lush.hsl

-- TODO(skip): remove
local cube = { 0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff }
local function joe(rgb)
  -- convert joe jsf "251" (in "fg_251") -> "#66ff33"
  local r, g, b = rgb:match('^([0-5])([0-5])([0-5])$')
  if not r then
    return nil, "expected 3 digits in range 0-5, e.g. '411'"
  end

  r, g, b = tonumber(r), tonumber(g), tonumber(b)
  local color =
    string.format('#%02x%02x%02x', cube[r + 1], cube[g + 1], cube[b + 1])
  return lush.hsl(color)
end

-- TODO(skip): remove
local ega = {
  black = H('#000000'),
  blue = H('#0000aa'),
  green = H('#00aa00'),
  cyan = H('#00aaaa'),
  red = H('#aa0000'),
  magenta = H('#aa00aa'),
  yellow = H('#aa5500'),
  white = H('#aaaaaa'),

  brblack = H('#555555'),
  brblue = H('#5555ff'),
  brgreen = H('#55ff55'),
  brcyan = H('#55ffff'),
  brred = H('#ff5555'),
  brmagenta = H('#ff55ff'),
  bryellow = H('#ffff55'),
  brwhite = H('#ffffff'),
}

-- actually configured in terminal; referenced here as base
local cur = H('#e60000')

local C = {
  void = H('#000000'),
  forest = H('#00bf36'), -- green
  glow = H('#333350'), -- bluish gray
  taro = H('#9681ff'), -- a nice purple
  pink = H('#ff81db'),
  red = H('#ff6366'),
  sea = H('#00c3c4'), -- cyan
  silver = H('#cccccc'),
  golden = H('#b76c2a'), -- brown/orange
  electron = H('#b7b22a'), -- yellow
}
local P = {
  kw_return = C.forest,
  kw_conditional = C.sea.ro(31).li(50).de(30),
  kw_repeat = C.golden.li(16),

  -- e.g. https://youtu.be/eXU-6_jmw7Q?t=820
  glow = C.glow,

  assign = C.red,

  operator = C.electron.ro(-5).li(30),

  string_delim = C.pink.da(20).de(10),
  string = C.pink,

  -- for structs, types, interfaces, etc. we are defining
  typedef = C.taro,
}

---@diagnostic disable: undefined-global
local spec = lush(function(injected_fns)
  local sym = injected_fns.sym
  return {
    Normal { bg = C.void, fg = ega.white },
    NormalFloat { bg = Normal.bg.li(7), fg = Normal.fg },
    -- NormalNC { bg = Normal.bg.li(10), fg = Normal.bg.li(70) },

    -- `skip.peeking` - oklch h283
    NormalPeek { bg = H('#0e0038').da(30), fg = '#a7a8bc' },
    CursorLinePeek { bg = NormalPeek.bg.li(10).de(30) },

    Comment { fg = C.golden, gui = 'italic' },
    MiniHipatternsTodo { fg = Comment.fg.li(50), bg = 'NONE' },
    MiniHipatternsNote { fg = Comment.fg.li(50), bg = 'NONE' },
    MiniHipatternsHack { fg = ega.brred, bg = 'NONE' },
    MiniHipatternsFixme { fg = ega.brred, bg = 'NONE', gui = 'reverse' },

    sym '@property.yaml' { fg = Normal.fg },

    Search {
      fg = ega.magenta.li(70).de(10),
      bg = ega.magenta.da(10),
      gui = 'underline',
    },
    CurSearch {
      fg = ega.brwhite,
      bg = ega.brmagenta.da(30),
      gui = 'bold, underline',
    },
    MatchParen {
      fg = ega.cyan.da(85),
      bg = ega.cyan,
      gui = 'italic',
    },

    -- reset a bunch of noisy default highlights {{{
    Function { fg = 'NONE' },
    Constant { fg = 'NONE' },
    sym '@function.builtin' { fg = 'NONE' },
    sym '@property' { fg = 'NONE' },
    Identifier { fg = 'NONE' },
    sym '@variable' { fg = 'NONE' },
    -- }}}

    -- keywords/types: bright white
    sym '@keyword' { fg = C.silver, gui = 'bold' },
    sym '@type.builtin' { fg = C.silver },
    Type { fg = C.silver },
    sym '@boolean' { Type },
    Special { fg = 'NONE' },

    -- return
    sym '@keyword.return' { fg = P.kw_return, gui = 'bold' },
    -- for while
    sym '@keyword.repeat' { fg = P.kw_repeat, gui = 'bold' },
    -- if else switch case
    sym '@keyword.conditional' { fg = P.kw_conditional, gui = 'bold' },

    -- types we are declaring
    sym '@type.definition' { fg = P.typedef, gui = 'bold' },
    sym '@lsp.typemod.class.declaration' { fg = P.typedef, gui = 'bold' },

    -- TODO(skip): maybe this should be something else
    NonText { fg = Normal.fg },
    SpecialKey { fg = Normal.fg },

    Delimiter { fg = Normal.fg.da(30) },
    sym '@lsp.type.operator.rust' { Delimiter }, -- rust ::
    sym '@punctuation' { fg = Delimiter.fg },
    Operator { fg = P.operator, gui = 'bold' },
    -- = := += -= /= *= &= |= etc.
    sym '@operator.assign' { fg = P.assign, gui = 'bold' },

    sym '@number' { fg = joe('315') },
    -- (fallback highlighting)
    javaScriptNumber { sym '@number' },

    -- strings
    sym '@string.delimiter' { fg = P.string_delim },
    sym '@string.escape' { fg = P.string.li(30), gui = 'bold' },
    String { fg = P.string },

    -- sql {{{
    -- e.g. table names
    sym '@type.sql' { fg = 'NONE' },
    sym '@keyword.insert.sql' { fg = ega.brgreen.li(20), gui = 'bold' },
    sym '@keyword.drop.sql' { fg = ega.red.li(90), bg = ega.red, gui = 'bold' },
    sym '@keyword.delete.sql' { sym '@keyword.drop.sql' },
    sym '@keyword.update.sql' { fg = Operator.fg, gui = 'bold' },
    -- }}}

    CursorLine { bg = cur.da(65) },
    LineNr { fg = joe('222') },
    LineNrAbove { fg = joe('322') },
    LineNrBelow { fg = joe('232') },
    CursorLineNr { bg = CursorLine.bg, fg = '#ffecc3', gui = 'bold' },
    CursorLineSign { CursorLineNr },
    CursorLineFold { CursorLineNr },

    -- incidentally matches w/ *Peek above
    ColorColumn { bg = NormalPeek.bg.li(10).de(30) },

    StatusLine { bg = cur.da(40), fg = '#ffecc3', gui = 'bold' },
    StatusLineNC { bg = Normal.bg.li(15) },
    WinSeparator { fg = Normal.fg, bg = StatusLineNC.bg },

    Folded { fg = P.glow.li(80), bg = P.glow, gui = 'bold,italic' },

    LspCodeLens { fg = Folded.bg.li(15).de(40), gui = 'italic' },
    LspReferenceRead { bg = Folded.bg },
    LspReferenceText { bg = Folded.bg },
    LspReferenceWrite { bg = Folded.bg },
    LspReferenceTarget { bg = Folded.bg },

    Directory { fg = C.sea },

    Visual { gui = 'reverse' },
    Error { bg = ega.red, fg = ega.brwhite, gui = 'bold' },
    ErrorMsg { Error },

    TabLine {},
    TabLineSel { StatusLine },
    TabLineFill { bg = 'NONE' },

    Title { fg = Operator.fg },
    sym '@markup.raw.vimdoc' { fg = C.silver },
    sym '@markup.raw.block.vimdoc' {},
    sym '@variable.parameter.vimdoc' { fg = ega.green },
    sym '@markup.link.vimdoc' { fg = String.fg, gui = 'underline' },

    ModeMsg { fg = ega.brgreen },
    MoreMsg { fg = ega.brmagenta },
    Question { fg = ega.brmagenta },
    WarningMsg { fg = ega.bryellow },

    DiffAdd { bg = joe('010').da(40) },
    DiffRemove { bg = joe('100') },
    DiffDelete { fg = joe('100').li(80), bg = joe('100') },
    DiffChange {
      bg = ega.magenta.da(40),
      fg = ega.magenta.li(80),
    },
    DiffText { DiffChange },

    -- are these standard or just a mini.diff thing?
    Added { fg = ega.brgreen },
    Changed { fg = ega.brmagenta },
    Removed { fg = ega.brred },

    -- telescope {{{
    TelescopeNormal { NormalFloat },
    TelescopePreviewNormal { fg = NormalFloat.fg, bg = NormalFloat.bg.li(5) },
    TelescopeSelection { CurSearch, gui = 'bold' },
    TelescopeMatching { gui = 'bold', bg = Search.bg },
    -- }}}

    -- diagnostics {{{
    DiagnosticError { fg = ega.brred },
    DiagnosticUnderlineError { sp = DiagnosticError.fg, gui = 'undercurl' },
    DiagnosticWarn { fg = ega.bryellow },
    DiagnosticUnderlineWarn { sp = DiagnosticWarn.fg, gui = 'undercurl' },
    DiagnosticInfo { fg = ega.brblue },
    DiagnosticUnderlineInfo { sp = DiagnosticInfo.fg, gui = 'undercurl' },
    DiagnosticHint { fg = ega.brgreen },
    DiagnosticUnderlineHint { sp = DiagnosticHint.fg, gui = 'undercurl' },
    DiagnosticOk { fg = ega.brgreen },
    DiagnosticUnderlineOk { sp = DiagnosticOk.fg, gui = 'undercurl' },
    -- }}}

    SpellBad { sp = ega.brred, gui = 'undercurl' },
    SpellCap { sp = ega.bryellow, gui = 'undercurl' },
    SpellLocal { sp = ega.brgreen, gui = 'undercurl' },
    SpellRare { sp = ega.brblue, gui = 'undercurl' },

    -- mini {{{
    MiniIndentscopeSymbol { fg = joe('111') },
    -- }}}
  }
end)

return spec
