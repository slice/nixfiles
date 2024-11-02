vim.g.mapleader = ' '

local opt = vim.opt

opt.title = true
opt.titlestring = [[%F]]
opt.breakindent = true
opt.colorcolumn = { 81 }
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.cursorline = true
opt.diffopt:append { 'linematch:60' }
opt.hidden = true
opt.ignorecase = true
opt.inccommand = 'nosplit'
opt.pumheight = 20
opt.formatoptions = 'jcroql'
opt.jumpoptions = 'view'
opt.list = true
opt.diffopt = {
  'internal',
  'filler',
  'closeoff',
  'linematch:60',
  'indent-heuristic',
  'algorithm:patience',
}
opt.listchars =
{ tab = '  ', trail = '·', nbsp = '+', precedes = '‹', extends = '›' }
opt.foldtext = ''
opt.fillchars:append { fold = '-' }
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
opt.spelloptions = { 'camel' }
opt.splitright = true
opt.sidescroll = 5
opt.signcolumn = 'yes:2'
opt.showbreak = '>'
opt.sidescrolloff = 10
opt.smartcase = true
do
  _G.RIGHT_STATUSLINE = function()
    local ok, fugitive_output = pcall(vim.fn.FugitiveStatusline)
    if not ok then
      return ''
    else
      return fugitive_output
    end
  end

  opt.statusline =
  [[%f%( %m%)%( [%R%H%W]%)%=%( %{v:lua.RIGHT_STATUSLINE()}%) %y %l/%L,%c #%n%<]]
end
opt.timeoutlen = 500
opt.undofile = true
opt.scrolloff = 5

-- blending is extremely important! how will i get work done without it?
-- local blend = 10
-- opt.pumblend = blend
-- opt.winblend = blend

-- render real tabs as being 8 spaces wide ...
opt.tabstop = 8

-- ... but indent with 2 sapces
opt.expandtab = true
opt.softtabstop = 2
opt.shiftwidth = 2

-- avoid loading the autoload portions of netrw so "e ." uses dirvish, but we
-- can still use :GBrowse from fugitive
vim.g.loaded_netrwPlugin = true

vim.g.markdown_fenced_languages = { 'ts=typescript' }

do
  function _G._STATUSCOLUMN()
    local num = vim.v.lnum
    local num_relative = vim.v.lnum - vim.fn.line('.')

    if num_relative == 0 then
      return num
    else
      local positive = num_relative > 0
      local symbol = positive and '󰐕 ' or '󰍴 '
      return symbol .. tostring(math.abs(num_relative))
    end
  end

  function _G._SET_STATUSCOLUMN(winid)
    -- %= right aligns (important)
    local value = [[%C%s %=%{%v:lua._STATUSCOLUMN()%}│ ]]
    if winid == nil then
      vim.o.statuscolumn = value
    else
      vim.wo[winid][0].statuscolumn = value
    end
  end

  _G._SET_STATUSCOLUMN()
end
