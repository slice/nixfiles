-- TODO: integrate lush into colorscheme tweaks system? :3

vim.opt.background = "dark"
vim.g.colors_name = "skipbones"

local lush = require "lush"
local seoul = require "seoulbones"

local skipbones = lush.extends({ seoul }).with(function(injected)
  local sym = injected.sym

  --- @diagnostic disable: undefined-global
  return {
    Normal { seoul.Normal, bg = seoul.Normal.bg.darken(8) },

    ColorColumn { bg = seoul.Normal.bg.darken(20) },

    Cursor { fg = seoul.Normal.fg, bg = lush.hsl "#c22125" },
    CursorLine { bg = Cursor.bg.darken(35).desaturate(60) },
    CursorLineNr { seoul.CursorLineNr, bg = CursorLine.bg },

    TelescopeNormal { seoul.NormalFloat },
    TelescopeMatching { seoul.CursorLineNr, fg = Cursor.bg.desaturate(50).lighten(40), gui = "bold" },
    TelescopeSelectionCaret { CursorLineNr },

    StatusLine { seoul.StatusLine, gui = "bold, reverse" },

    String { seoul.String, gui = "" },
    Number { seoul.Number, gui = "" },
    Constant { seoul.Constant, gui = "" },

    TabLine { bg = seoul.TabLineFill.bg },
    TabLineSel { gui = "bold, reverse" },

    DirvishPathTail { seoul.Statement },

    fugitiveUnstagedHeading { seoul.PreProc },
    fugitiveUntrackedHeading { seoul.Type },
    fugitiveStagedHeading { seoul.diffAdded },

    gitcommitSummary { seoul.WarningMsg },

    SpellBad { gui = "undercurl", sp = seoul.ErrorMsg.fg },
  }
  --- @diagnostic enable: undefined-global
end)

lush(skipbones)
