-- vim: set fdm=marker:

local lush = require 'lush'
local H = lush.hsl

---@diagnostic disable: undefined-global
local spec = lush(function(injected_fns)
  local sym = injected_fns.sym
  local bg = H('#0E272C')
  local fg = H('#D0C0A0').li(20)

  return {
    Normal { bg = bg, fg = fg },
    NormalFloat { Normal, bg = bg.da(20).de(20) },
    TelescopeNormal { NormalFloat },
    NonText { fg = bg.li(40).de(30) },
    Comment { fg = H('#40C040') },
    Delimiter { fg = fg.da(40).de(50) },

    MatchParen { bg = H('#70e8b4'), fg = H('#003c22'), gui = 'bold' },

    Pmenu { NormalFloat },
    PmenuSel { gui = 'reverse,bold' },

    CursorLine { bg = Normal.bg.da(40) },
    CursorLineNr { CursorLine },
    CursorLineSign { CursorLine },
    CursorLineFold { CursorLine },
    LineNr { fg = bg.li(20) },
    ColorColumn { bg = Normal.bg.li(5) },

    StatusLine { gui = 'bold,reverse' },
    StatusLineNC { bg = 'NONE', fg = 'NONE' },

    Keyword { fg = '#ffffff' },
    sym '@keyword' { Keyword },
    Number { fg = H('#80F0E0') },
    String { fg = H('#40B0A0') },
    Visual { bg = H('#0010FF') },

    LspReferenceRead { fg = 'NONE', bg = 'NONE' },
    LspReferenceText { fg = 'NONE', bg = 'NONE' },
    LspReferenceWrite { fg = 'NONE', bg = 'NONE' },
    LspReferenceTarget { fg = 'NONE', bg = 'NONE' },

    -- reset a bunch of noisy default highlights {{{
    Function { fg = 'NONE' },
    Constant { fg = 'NONE' },
    Special { fg = 'NONE' }, -- for now
    Operator { fg = 'NONE' }, -- for now
    Statement { fg = 'NONE' },
    Type { fg = 'NONE' },
    sym '@function.builtin' { fg = 'NONE' },
    sym '@property' { fg = 'NONE' },
    Identifier { fg = 'NONE' },
    sym '@variable' { fg = 'NONE' },
    sym '@constructor.lua' { fg = 'NONE' },
    -- }}}

    MiniIndentscopeSymbol { fg = bg.li(10) },
  }
end)

return spec
