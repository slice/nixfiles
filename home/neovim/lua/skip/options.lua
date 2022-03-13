local opt = vim.opt

opt.colorcolumn = { 80, 120 }
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.cursorline = true
opt.cursorlineopt = { 'number' }
opt.guicursor:append({ 'a:blinkwait1000', 'a:blinkon1000', 'a:blinkoff1000' })
opt.ignorecase = true
opt.inccommand = 'nosplit'
opt.pumheight = 20
opt.list = true
opt.listchars = { tab = '> ', trail = '·', nbsp = '+' }
opt.modeline = true
opt.mouse = 'a'
opt.swapfile = false
opt.termguicolors = true
-- lower the duration to trigger CursorHold for faster hovers. we won't be
-- updating swapfiles this often because they're turned off.
opt.updatetime = 1000
opt.wrap = false
opt.number = true
opt.relativenumber = true
opt.splitright = true
opt.sidescrolloff = 10
-- don't give the intro message and file editing messages
opt.shortmess:append('I'):remove('F')
opt.smartcase = true
opt.statusline = [[%c,%l/%L %f%H %r%m%=%y (%P)]]
opt.shada = [['1000]] -- remember 1,000 oldfiles
opt.undodir = vim.fn.stdpath('data') .. '/undo'
opt.undofile = true

-- blending is extremely important! how will i get work done without it?
local blend = 10
opt.pumblend = blend
opt.winblend = blend

-- actual tabs are 8 spaces long ...
opt.tabstop = 8

-- ... but indent with 2 sapces
opt.expandtab = true
opt.softtabstop = 2
opt.shiftwidth = 2
