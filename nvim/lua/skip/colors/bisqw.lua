-- vim: set fdm=marker:
-- something vaguely resembling bisqwit (https://bisqwit.iki.fi/)'s theme, but
-- heavily edited for my own weird needs

local lush = require 'lush'

-- TODO(skip): uhhhhh this looks really wrong?
local cube = { 0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff }
local function joe(rgb)
  -- convert joe jsf "251" (in "fg_251") -> "#66ff33"
  local r, g, b = rgb:match('^([0-5])([0-5])([0-5])$')
  if not r then
    return nil, "expected 3 digits in range 0-5, e.g. '411'"
  end

  r, g, b = tonumber(r), tonumber(g), tonumber(b)
  return string.format('#%02x%02x%02x', cube[r + 1], cube[g + 1], cube[b + 1])
end

local ega = {
  black = '#000000',
  blue = '#0000aa',
  green = '#00aa00',
  cyan = '#00aaaa',
  red = '#aa0000',
  magenta = '#aa00aa',
  yellow = '#aa5500',
  white = '#aaaaaa',

  brblack = '#555555',
  brblue = '#5555ff',
  brgreen = '#55ff55',
  brcyan = '#55ffff',
  brred = '#ff5555',
  brmagenta = '#ff55ff',
  bryellow = '#ffff55',
  brwhite = '#ffffff',
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
  local cur = lush.hsl('#e60000')
  -- joe "fg_xxx" colors
  local palette = {
    assign = joe('251'),
    string_delim = joe('024'),
    string = joe('035'),
  }
  -- any other true colors
  local other = {
    -- e.g. https://youtu.be/eXU-6_jmw7Q?t=820
    glow = '#333350',
  }

  return {
    Normal { bg = '#000000', fg = ega.white },

    -- `skip.peeking` - oklch h283
    NormalPeek { bg = lush.hsl('#0e0038').da(30), fg = '#a7a8bc' },
    CursorLinePeek { bg = NormalPeek.bg.li(10).de(30) },

    -- Comment { fg = '#ff5555' },
    -- DEVIATING: reserving red for cursor/current pos (done in term. config)
    Comment { fg = lush.hsl('#9a5e25'), gui = 'italic' },
    MiniHipatternsTodo { fg = Comment.fg.li(50), bg = 'NONE' },
    MiniHipatternsNote { fg = Comment.fg.li(50), bg = 'NONE' },
    MiniHipatternsHack { fg = ega.brred, bg = 'NONE' },
    MiniHipatternsFixme { fg = ega.brred, bg = 'NONE', gui = 'reverse' },

    -- reset a bunch of noisy default highlights {{{
    Function { fg = 'NONE' },
    Constant { fg = 'NONE' },
    sym '@function.builtin' { fg = 'NONE' },
    sym '@property' { fg = 'NONE' },
    Identifier { fg = 'NONE' },
    sym '@variable' { fg = 'NONE' },
    -- }}}

    -- keywords/types: brwhite
    sym '@keyword' { fg = ega.brwhite },
    sym '@type.builtin' { fg = ega.brwhite },
    Type { fg = ega.brwhite },
    sym '@boolean' { Type },
    Special { fg = 'NONE' },

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
    sym '@keyword.drop.sql' { fg = ega.red, gui = 'reverse' },
    sym '@keyword.update.sql' { fg = Operator.fg },
    -- }}}

    CursorLine { bg = cur.da(75) },
    LineNr { fg = joe('222') },
    LineNrAbove { fg = joe('322') },
    LineNrBelow { fg = joe('232') },
    CursorLineNr { fg = cur.da(75), bg = Normal.fg },
    CursorLineSign { CursorLineNr },
    CursorLineFold { CursorLineNr },

    -- incidentally matches w/ *Peek above
    ColorColumn { bg = NormalPeek.bg.li(10).de(30) },

    StatusLine { bg = cur.da(40), fg = '#ffecc3' },
    StatusLineNC { bg = 'NONE' },

    Folded { fg = Normal.fg, bg = other.glow },

    Directory { fg = Operator.fg },

    Visual { gui = 'reverse' },
    Error { bg = ega.red, fg = ega.brwhite },
    ErrorMsg { Error },

    TabLine {},
    TabLineSel { StatusLine },
    TabLineFill { bg = 'NONE' },
    -- technically this is also used in :changes and other places, but just
    -- treat this as the number in tab line tabs
    Title { bg = 'NONE', fg = 'NONE' },

    ModeMsg { fg = ega.brgreen },
    MoreMsg { fg = ega.brmagenta },
    Question { fg = ega.brmagenta },
    WarningMsg { fg = ega.bryellow },

    -- diagnostics {{{
    DiagnosticError { fg = ega.red },
    DiagnosticWarn { fg = ega.bryellow },
    DiagnosticInfo { fg = ega.brblue },
    DiagnosticHint { fg = ega.brgreen },
    DiagnosticOk { fg = ega.brgreen },
    -- }}}

    -- mini {{{
    MiniIndentscopeSymbol { fg = joe('111') },
    -- }}}
  }
end)

return spec
