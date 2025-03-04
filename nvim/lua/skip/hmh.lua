local lush = require 'lush'
local hsl = lush.hsl

---@diagnostic disable: undefined-global
return lush(function(inj)
  local sym = inj.sym

  return {
    Normal { bg = hsl '#080808', fg = hsl '#b7a795' },
    Cursor { bg = hsl '#3eed3d', fg = Normal.bg },
    ModeMsg { fg = Cursor.bg, bold = true },
    CursorLine { bg = hsl '#09096d' },
    CursorLineNr { CursorLine, fg = Normal.fg, bold = true, italic = true },
    Comment { fg = hsl '#727472'.li(10) },
    PreProc { fg = Comment.fg.li(60), italic = true },
    LineNr { fg = Normal.bg.li(30) },
    ColorColumn { bg = Normal.bg.li(9) },

    Constant { fg = hsl '#698929' },
    String { fg = Constant.fg.li(10) },
    Delimiter { fg = Normal.fg.da(50) },
    Special { fg = Normal.fg.sa(20).li(30), bold = true },

    StatusLine { fg = hsl '#eeeeee'.da(20), bg = Normal.bg, reverse = true },
    StatusLineNC { fg = Comment.fg, bg = Normal.bg },

    MiniHipatternsTodo { fg = '#d80a06', bold = true, underline = true },
    MiniHipatternsFixme {
      fg = '#d80a06',
      bold = true,
      underline = true,
      italic = true,
    },
    MiniHipatternsNote { fg = '#045f03', bold = true, underline = true },

    sym '@lsp.type.macro' { Special },

    CurSearch {
      bg = hsl '#ef799e',
      fg = hsl '#ef799e'.da(40).de(20),
      bold = true,
    },
    Search { bg = CurSearch.fg.da(40), fg = CurSearch.fg.li(30) },

    Visual { bg = hsl '#ffff00'.ro(-10).da(5).li(20), fg = hsl '#000000' },
    TelescopeSelection { Visual },
    TelescopeMatching { Visual, bold = true },

    -- keywords
    Conditional { fg = hsl '#8e6a23'.li(10).de(15) },
    sym '@keyword' { Conditional },
    Repeat { Conditional },
    Label { Conditional },
    Keyword { Conditional },

    -- "wtf" resets
    sym '@variable' { reset = true },
    Identifier { reset = true },
    Statement { reset = true },
    Function { reset = true },
    Operator { reset = true },
    Type { reset = true },
    sym '@constructor.lua' { reset = true },
  }
end)
