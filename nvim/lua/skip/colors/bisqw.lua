-- vim: set fdm=marker:

-- something vaguely resembling bisqwit (https://bisqwit.iki.fi/)'s theme, but
-- heavily edited for my own weird needs

local lush = require 'lush'
local H = lush.hsl

-- TODO(skip): uhhhhh this looks really wrong?
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

---@diagnostic disable: undefined-global
local spec = lush(function(injected_fns)
  local sym = injected_fns.sym

  -- color references:
  --
  -- * https://github.com/bisqwit/compiler_series/blob/4c813f58b0f727c009e6a5a68a165246fbcd1fad/ep1/ccat/c.jsf
  -- * "modern" bisqwit syntax: youtube.com/watch?v=Nwfm6cpskIM
  --   * uses lavender for numbers

  -- actually configured in terminal; referenced here as base
  local cur = H('#e60000')
  -- joe "fg_xxx" colors
  local palette = {
    assign = joe('251'),
    string_delim = joe('024'),
    string = joe('035'),
  }
  -- any other true colors
  local other = {
    -- e.g. https://youtu.be/eXU-6_jmw7Q?t=820
    glow = H('#333350'),
  }

  return {
    Normal { bg = H('#000000'), fg = ega.white },
    NormalFloat { bg = Normal.bg.li(14), fg = Normal.fg },
    -- NormalNC { bg = Normal.bg.li(10), fg = Normal.bg.li(70) },

    -- `skip.peeking` - oklch h283
    NormalPeek { bg = H('#0e0038').da(30), fg = '#a7a8bc' },
    CursorLinePeek { bg = NormalPeek.bg.li(10).de(30) },

    -- Comment { fg = '#ff5555' },
    -- DEVIATING: reserving red for cursor/current pos (done in term. config)
    Comment { fg = H('#9a5e25'), gui = 'italic' },
    MiniHipatternsTodo { fg = Comment.fg.li(50), bg = 'NONE' },
    MiniHipatternsNote { fg = Comment.fg.li(50), bg = 'NONE' },
    MiniHipatternsHack { fg = ega.brred, bg = 'NONE' },
    MiniHipatternsFixme { fg = ega.brred, bg = 'NONE', gui = 'reverse' },

    Search {
      fg = ega.magenta.li(70).de(10),
      bg = ega.magenta.da(10),
      gui = 'underline',
    },
    CurSearch {
      fg = ega.brwhite,
      bg = ega.brmagenta.da(10),
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

    -- keywords/types: brwhite
    sym '@keyword' { fg = ega.brwhite, gui = 'bold' },
    sym '@type.builtin' { fg = ega.brwhite },
    Type { fg = ega.brwhite },
    sym '@boolean' { Type },
    Special { fg = 'NONE' },

    -- DEVIATING: `return` gets special hl
    sym '@keyword.return' { fg = lush.hsl('#cc6600').li(40), gui = 'bold' },

    -- TODO(skip): maybe this should be something else
    NonText { fg = Normal.fg },
    SpecialKey { fg = Normal.fg },

    -- green            [ ] { } , ;
    sym '@punctuation.bracket.square' { fg = ega.green },
    sym '@punctuation.bracket.brace' { fg = ega.green },
    sym '@punctuation.comma' { fg = ega.green },
    -- cyan             ( ) : . *  default for operators
    sym '@punctuation.bracket.paren' { fg = joe('033') },
    sym '@punctuation.period' { fg = joe('033') },
    Operator { fg = joe('033') },
    Delimiter { Operator },
    -- brgreen variant  = := += -= /= *= &= |= etc.
    sym '@operator.assign' { fg = palette.assign },

    -- magenta          numbers
    sym '@number' { fg = joe('315') },
    javaScriptNumber { sym '@number' },

    -- strings: blue-y
    sym '@string.delimiter' { fg = palette.string_delim },
    String { fg = palette.string },
    sym '@string' { fg = String.fg },

    -- wtf lua {{{
    sym '@punctuation.bracket.lua' { sym '@punctuation.bracket.brace' },
    sym '@constructor.lua' {},
    -- }}}

    -- sql {{{
    -- e.g. table names
    sym '@type.sql' { fg = 'NONE' },
    sym '@keyword.insert.sql' { fg = palette.assign },
    sym '@keyword.drop.sql' { fg = ega.red.li(90), bg = ega.red },
    sym '@keyword.update.sql' { fg = Operator.fg },
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

    Folded { fg = other.glow.li(80), bg = other.glow, gui = 'bold,italic' },

    LspCodeLens { fg = Folded.bg.li(15).de(40), gui = 'italic' },
    LspReferenceRead { bg = Folded.bg },
    LspReferenceText { bg = Folded.bg },
    LspReferenceWrite { bg = Folded.bg },
    LspReferenceTarget { bg = Folded.bg },

    Directory { fg = Operator.fg },

    Visual { gui = 'reverse' },
    Error { bg = ega.red, fg = ega.brwhite },
    ErrorMsg { Error },

    TabLine {},
    TabLineSel { StatusLine },
    TabLineFill { bg = 'NONE' },

    Title { fg = Operator.fg },
    sym '@markup.raw.vimdoc' { fg = ega.brwhite },
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
