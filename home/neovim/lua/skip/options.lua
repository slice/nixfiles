local opt = vim.opt

_G.RIGHT_STATUSLINE = function()
  local ok, fugitive_output = pcall(vim.fn.FugitiveStatusline)
  if not ok then
    return ""
  else
    return fugitive_output
  end
end

opt.title = true
opt.titlestring = [[%F]]
opt.breakindent = true
opt.colorcolumn = { 81, 121 }
opt.completeopt = { "menu", "menuone", "noselect" }
opt.cursorline = true
opt.diffopt:append { "linematch:60" }
opt.hidden = false
opt.guicursor:append { "a:blinkwait1000", "a:blinkon1000", "a:blinkoff1000" }
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.pumheight = 20
opt.jumpoptions = "view"
opt.list = true
opt.listchars = { tab = "> ", trail = "·", nbsp = "+", precedes = "<", extends = ">" }
opt.modeline = true
opt.mouse = "a"
opt.swapfile = false
opt.termguicolors = true
-- lower the duration to trigger CursorHold for faster hovers. we won't be
-- updating swapfiles this often because they're turned off.
opt.updatetime = 1000
opt.wrap = false
opt.number = true
opt.relativenumber = true
opt.spell = true
opt.spelloptions = { "camel" }
opt.splitright = true
opt.sidescroll = 5
opt.showbreak = ">"
opt.sidescrolloff = 10
opt.smartcase = true
opt.statusline = [[%<%f%( %m%)%( [%R%H%W]%)%=%( %{v:lua.RIGHT_STATUSLINE()}%) %c,%l/%L #%n]]
opt.timeoutlen = 500
opt.shada = [['1000]] -- remember 1,000 oldfiles
opt.undofile = true
opt.scrolloff = 5

-- blending is extremely important! how will i get work done without it?
local blend = 10
opt.pumblend = blend
opt.winblend = blend

-- render real tabs as being 8 spaces wide ...
opt.tabstop = 8

-- ... but indent with 2 sapces
opt.expandtab = true
opt.softtabstop = 2
opt.shiftwidth = 2

local g = vim.g

-- avoid loading the autoload portions of netrw so "e ." uses dirvish, but we
-- can still use :GBrowse from fugitive
g.loaded_netrwPlugin = true

-- colorschemes
g.seoul256_background = 236
g.zenburn_old_Visual = true
g.zenburn_alternate_Visual = true
g.zenburn_italic_Comment = true
g.zenburn_subdued_LineNr = true
g.nightflyCursorColor = true
g.nightflyUndercurls = false
g.nightflyItalics = false
g.moonflyCursorColor = true
g.moonflyUndercurls = false
g.moonflyItalics = true

g.rooter_patterns = { ".git" }
g.rooter_manual_only = true
g.rooter_cd_cmd = "tcd"

g.everforest_ui_contrast = 1
