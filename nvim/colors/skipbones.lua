-- TODO: integrate lush into colorscheme tweaks system? :3

vim.opt.background = "dark"
vim.g.colors_name = "skipbones"

local lush = require "lush"
local seoul = require "seoulbones"

local skipbones = lush.extends({ seoul }).with(function(injected)
  local sym = injected.sym

  --- @diagnostic disable: undefined-global
  return {
    Normal { seoul.Normal, bg = seoul.Normal.bg.darken(20) },
    NormalFloat { bg = lush.hsl "#515151" },

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
    Boolean { seoul.Number, gui = "bold" },

    TabLine { bg = seoul.TabLineFill.bg },
    TabLineSel { gui = "bold, reverse" },

    DirvishPathTail { seoul.Statement },

    fugitiveUnstagedHeading { seoul.PreProc },
    fugitiveUntrackedHeading { seoul.Type },
    fugitiveStagedHeading { seoul.diffAdded },

    gitcommitSummary { seoul.WarningMsg },

    SpellBad { gui = "undercurl", sp = seoul.ErrorMsg.fg },

    QuickFixLine { seoul.Visual },

    Added { bg = seoul.DiffAdd.bg },
    Changed { bg = seoul.DiffChange.bg },
    Removed { bg = seoul.DiffDelete.bg },

    MiniMapNormal { fg = Normal.fg.darken(50) },
  }
  --- @diagnostic enable: undefined-global
end)

lush(skipbones)
local palette = require("seoulbones.palette")[vim.o.background]
require("zenbones.term").apply_colors(palette)
vim.g.terminal_color_8 = "#999999"
vim.g.terminal_color_0 = "#333333"
