-- TODO: integrate lush into colorscheme tweaks system? :3

vim.opt.background = "dark"
vim.g.colors_name = "skipbones"

local lush = require "lush"
local sb = require "seoulbones"

local spec = lush.extends({ sb }).with(function()
  --- @diagnostic disable: undefined-global
  return {
    Normal { sb.Normal, bg = sb.Normal.bg.darken(8) },

    ColorColumn { bg = sb.Normal.bg.darken(20) },

    Cursor { fg = sb.Normal.fg, bg = lush.hsl "#c22125" },
    CursorLine { bg = Cursor.bg.darken(35).desaturate(60) },
    CursorLineNr { sb.CursorLineNr, bg = CursorLine.bg },

    TelescopeNormal { sb.NormalFloat },
    TelescopeSelectionCaret { CursorLineNr },

    StatusLine { sb.StatusLine, gui = "reverse" },

    String { sb.String, gui = "" },
    Number { sb.Number, gui = "" },
    Constant { sb.Constant, gui = "" },

    TabLine { bg = sb.TabLineFill.bg },
    TabLineSel { gui = "bold, reverse" },
  }
  --- @diagnostic enable: undefined-global
end)

lush(spec)
