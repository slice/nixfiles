-- TODO: integrate lush into colorscheme tweaks system? :3

vim.opt.background = 'dark'
vim.g.colors_name = 'skipbones'

local lush = require 'lush'
local seoul = require 'seoulbones'

local skipbones = lush.extends({ seoul }).with(function(injected)
  local sym = injected.sym
  local attention = lush.hsl '#c22125'

  --- @diagnostic disable: undefined-global
  return {
    Normal { seoul.Normal, bg = seoul.Normal.bg.darken(20) },
    NormalNC { bg = Normal.bg.lighten(15) },
    NormalFloat { bg = lush.hsl '#515151' },

    ColorColumn { bg = Normal.bg.darken(5) },

    Cursor { fg = seoul.Normal.fg, bg = attention },
    CursorLine { bg = attention.darken(40).desaturate(50) },
    CursorLineSign { bg = CursorLine.bg },
    CursorLineNr {
      fg = seoul.CursorLineNr.fg.saturate(30),
      bg = CursorLine.bg,
      gui = 'bold',
    },
    LineNrAbove { fg = seoul.LineNr.fg.saturate(10).darken(10) },
    LineNrBelow { fg = seoul.LineNr.fg.hue(120).saturate(10).darken(10) },
    TelescopeNormal { seoul.NormalFloat },
    TelescopeMatching {
      seoul.CursorLineNr,
      fg = attention.desaturate(50).lighten(40),
      gui = 'bold',
    },
    TelescopeSelectionCaret { CursorLineNr },

    StatusLine {
      fg = CursorLineNr.fg,
      bg = attention.desaturate(15),
      gui = 'bold',
    },
    ModeMsg { fg = lush.hsl '#ffffff', bg = lush.hsl '#008517', gui = 'bold' },

    String { seoul.String, gui = '' },
    Number { seoul.Number, gui = '' },
    Constant { seoul.Constant, gui = '' },
    Boolean { seoul.Number, gui = 'bold' },
    Operator { fg = Identifier.fg },

    TabLine { bg = seoul.TabLineFill.bg },
    TabLineSel { gui = 'bold, reverse' },

    DirvishPathTail { seoul.Statement },

    fugitiveUnstagedHeading { seoul.PreProc },
    fugitiveUntrackedHeading { seoul.Type },
    fugitiveStagedHeading { seoul.diffAdded },

    gitcommitSummary { seoul.WarningMsg },

    SpellBad { gui = 'undercurl', sp = seoul.ErrorMsg.fg },

    QuickFixLine { seoul.Visual },

    Added { bg = seoul.DiffAdd.bg },
    Changed { bg = seoul.DiffChange.bg },
    Removed { bg = seoul.DiffDelete.bg },

    MiniMapNormal { fg = Normal.fg.darken(50) },
  }
  --- @diagnostic enable: undefined-global
end)

lush(skipbones)
local palette = require('seoulbones.palette')[vim.o.background]
require('zenbones.term').apply_colors(palette)
vim.g.terminal_color_8 = '#999999'
vim.g.terminal_color_0 = '#333333'
