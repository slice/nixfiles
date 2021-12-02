-- vim: set fdm=marker:

-- .-------------------------------.
-- | slice's neovim 0.5+ config (: |
-- | <o_/ *quack* *quack*          |
-- '-------------------------------'
--
--      (nix edition!)

-- be lazy {{{

local cmd = vim.cmd
local fn = vim.fn
local opt = vim.opt

local g = vim.g

-- }}}

function greet()
  cmd [[echo "\_o> ♥ ♥ ♥ <o_/"]]
end

cmd [[command! Greet :lua greet()<CR>]]
greet()

-- options {{{

-- opt.cursorline = true
opt.colorcolumn = {80,120}
opt.completeopt = {'menu','menuone','noselect'}
opt.guicursor:append {'a:blinkwait1000', 'a:blinkon1000', 'a:blinkoff1000'}
opt.hidden = true
opt.ignorecase = true
opt.inccommand = 'nosplit'
opt.joinspaces = false
opt.list = true
opt.listchars = {tab='> ', trail='·', nbsp='+'}
opt.modeline = true
opt.mouse = 'a'
opt.swapfile = false
-- lower the duration to trigger CursorHold for faster hovers. we won't be
-- updating swapfiles this often because they're turned off.
opt.updatetime = 1000
opt.wrap = false
opt.number = true
opt.relativenumber = true
opt.splitright = true
opt.shortmess:append('I'):remove('F')
opt.smartcase = true
opt.statusline = [[%f %r%m%=%l/%L,%c (%P)]]
opt.shada = [['1000]] -- remember 1000 oldfiles
opt.termguicolors = true
opt.undodir = fn.stdpath('data') .. '/undo'
opt.undofile = true
local blend = 10
opt.pumblend = blend -- extremely important
opt.winblend = blend

opt.expandtab = true
opt.tabstop = 8
opt.softtabstop = 2
opt.shiftwidth = 2

-- }}}

-- plugin options {{{

-- avoid loading the autoload portions of netrw so "e ." uses dirvish, but we
-- can still use :GBrowse from fugitive
g.loaded_netrwPlugin = true

-- g['sneak#label'] = true
g['float_preview#docked'] = false
g.seoul256_background = 236
g.zenburn_old_Visual = true
g.zenburn_alternate_Visual = true
g.zenburn_italic_Comment = true
g.zenburn_subdued_LineNr = true

g.rooter_patterns = {'.git'}
g.rooter_manual_only = true
g.rooter_cd_cmd = 'tcd'

g.nightflyCursorColor = true
g.nightflyUndercurls = false
g.nightflyItalics = false

g.moonflyCursorColor = true
g.moonflyUndercurls = false
g.moonflyItalics = true

-- }}}

-- maps {{{

g.mapleader = ' '

-- from: https://github.com/wbthomason/dotfiles/blob/5117f6d76c64baa661368e85a25ca463ff858a05/neovim/.config/nvim/lua/config/utils.lua
local function map(modes, lhs, rhs, opts)
  opts = opts or {}
  if opts.noremap == nil then
    opts.noremap = true
  end
  if type(modes) == 'string' then
    modes = {modes}
  end
  for _, mode in ipairs(modes) do
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
  end
end

-- have i_CTRL-U make the previous word uppercase instead
map('i', '<c-u>', '<esc>gUiwea')

function POPTERM_TOGGLE()
  if IS_POPTERM() then
    -- if we're currently inside a popterm, just hide it
    POPTERM_HIDE()
  else
    POPTERM_NEXT()
  end
end

-- jump around windows easier. this is probably breaking something?
map('n', '<C-H>', '<C-W><C-H>')
map('n', '<C-J>', '<C-W><C-J>')
map('n', '<C-K>', '<C-W><C-K>')
map('n', '<C-L>', '<C-W><C-L>')

-- lsp...
function setup_lsp_buf()
  vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  map_buf('n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>')
  map_buf('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
  map_buf('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  map_buf('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>')
  map_buf('n', '<leader>lf', '<cmd>lua vim.lsp.buf.formatting_sync(nil, 2000)<CR>')
  vim.cmd([[autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics({ focusable = false })]])
end

-- nvim-popterm.lua
map('n', '<a-tab>', '<cmd>lua POPTERM_TOGGLE()<CR>')
map('t', '<a-tab>', '<cmd>lua POPTERM_TOGGLE()<CR>')
-- because neovide doesn't have some mappings yet because of keyboard support
map('n', '<leader>0', '<cmd> lua POPTERM_TOGGLE()<CR>')

-- cd to vcs root
map('n', '<leader>r', '<cmd>Rooter<CR>')

-- quickly open :terminals
map('n', '<leader>te', '<cmd>tabnew +terminal<CR>')
map('n', '<leader>ts', '<cmd>below split +terminal<CR>')
map('n', '<leader>tv', '<cmd>vsplit +terminal<CR>')

-- telescope
map('n', '<leader>o', '<cmd>Telescope find_files<CR>')
map('n', '<leader>i', '<cmd>Telescope oldfiles<CR>')
map('n', '<leader>b', '<cmd>Telescope buffers<CR>')

map('n', '<leader>lp', '<cmd>lua require"telescope".extensions.trampoline.trampoline.project{}<CR>')
map('n', '<leader>lt', '<cmd>Telescope builtin<CR>')
map('n', '<leader>lg', '<cmd>Telescope live_grep<CR>')
map('n', '<leader>lb', '<cmd>Telescope file_browser hidden=true<CR>')
map('n', '<leader>lc', '<cmd>Telescope colorscheme<CR>')
map('n', '<leader>lls', '<cmd>Telescope lsp_workspace_symbols<CR>')
map('n', '<leader>lld', '<cmd>Telescope lsp_workspace_diagnostics<CR>')
map('n', '<leader>llr', '<cmd>Telescope lsp_references<CR>')
map('n', '<leader>lla', '<cmd>Telescope lsp_code_actions<CR>')

-- vimrc; https://learnvimscriptthehardway.stevelosh.com/chapters/08.html
-- map('n', '<leader>ve', "bufname('%') == '' ? '<cmd>edit $MYVIMRC<CR>' : '<cmd>vsplit $MYVIMRC<CR>'", {expr = true})
-- map('n', '<leader>vs', '<cmd>luafile $MYVIMRC<CR>')
map('n', '<leader>ve', '<cmd>edit ~/src/prj/nixfiles/home/neovim<CR>')

-- neoformat
map('n', '<leader>nf', '<cmd>Neoformat<CR>')

-- align stuff easily
-- NOTE: need noremap=false because of <Plug>
map('x', 'ga', '<Plug>(EasyAlign)', {noremap = false})
map('n', 'ga', '<Plug>(EasyAlign)', {noremap = false})

-- Q enters ex mode by default, so let's bind it to gq instead
-- (as suggested by :h gq)
map('n', 'Q', 'gq', {noremap = false})
map('v', 'Q', 'gq', {noremap = false})

-- replace :bdelete with sayonara
map('c', 'bd', 'Sayonara!')

-- quick access to telescope
map('c', 'Ts', 'Telescope')

-- snippets.nvim
map('i', '<c-l>', "<cmd>lua return require'snippets'.expand_or_advance(1)<CR>")
map('i', '<c-h>', "<cmd>lua return require'snippets'.advance_snippet(-1)<CR>")

local command_aliases = {
  -- sometimes i hold down shift for too long o_o
  W = 'w',
  Wq = 'wq',
  Wqa = 'wqa',
  Q = 'q',
  Qa = 'qa',
  Bd = 'bd',
}

for lhs, rhs in pairs(command_aliases) do
  cmd(string.format('command! -bang %s %s<bang>', lhs, rhs))
end

-- maps so we can use :diffput and :diffget in visual mode
-- (can't use d because it means delete already)
map('v', 'fp', ":'<,'>diffput<CR>")
map('v', 'fo', ":'<,'>diffget<CR>")

-- }}}

-- autocmds {{{

-- from: https://github.com/wbthomason/dotfiles/blob/5117f6d76c64baa661368e85a25ca463ff858a05/neovim/.config/nvim/lua/config/utils.lua
local function aug(group, cmds)
  if type(cmds) == 'string' then
    cmds = {cmds}
  end
  cmd('augroup ' .. group)
  cmd('autocmd!') -- clear existing group
  for _, c in ipairs(cmds) do
    cmd('autocmd ' .. c)
  end
  cmd('augroup END')
end

-- personal colorscheme tweaks
aug('colorschemes', {
  'ColorScheme bubblegum-256-dark'
    .. ' highlight Todo gui=bold'
    .. ' | highlight Folded gui=reverse'
    .. ' | highlight! link MatchParen LineNr'
    .. ' | highlight! IndentBlanklineChar guifg=#3d3d3d'
    .. ' | highlight! link DiagnosticError Error'
    .. ' | highlight! link DiagnosticWarn Constant',
  -- style floating windows legible for popterms; make comments italic
  'ColorScheme landscape'
    .. ' highlight NormalFloat guifg=#dddddd guibg=#222222'
    .. ' | highlight Comment guifg=#999999 gui=italic',
  'ColorScheme zenburn'
    .. ' highlight! link TelescopeMatching IncSearch',
  'ColorScheme bubblegum-256-dark'
    .. ' highlight! link TelescopeMatching IncSearch',
  -- 'ColorScheme dogrun'
  --   .. ' highlight IndentBlanklineIndent1 guibg=#303345'
  --   .. ' | highlight IndentBlanklineIndent2 guibg=#303345'
})

-- metals_config = require("metals").bare_config
-- metals_config.settings = {
--   showImplicitArguments = true,
--   showInferredType = true
-- }

aug('metals', {
  'FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)'
    .. '; setup_lsp_buf()'
})

aug('hacks', {
  -- <c-x> opens splits in telescope, so we need this to be unmapped
  'VimEnter * silent! iunmap <c-x><c-a>'
})

aug('completion', {
  -- "BufEnter * lua require'completion'.on_attach()"
  -- 'CompleteDone * if pumvisible() == 0 | pclose | endif'
})

aug('filetypes', {
  -- enable spellchecking in git commits, reformat paragraphs as you type
  'FileType gitcommit setlocal spell formatoptions=tan | normal ] '
})

-- highlight when yanking (built-in)
aug('yank', 'TextYankPost * silent! lua vim.highlight.on_yank()')

local lang_indent_settings = {
  go = {width = 4, tabs = true},
  scss = {width = 2, tabs = false},
  sass = {width = 2, tabs = false},
}

local language_settings_autocmds = {}
for extension, settings in pairs(lang_indent_settings) do
  local width = settings['width']

  local expandtab = 'expandtab'
  if settings['tabs'] then
    expandtab = 'noexpandtab'
  end

  local autocmd = string.format(
    'FileType %s setlocal tabstop=%d softtabstop=%d shiftwidth=%d %s',
    extension, width, width, width, expandtab
  )
  table.insert(language_settings_autocmds, autocmd)
end

vim.list_extend(language_settings_autocmds, {
  'BufNewFile,BufReadPre *.sc,*.sbt setfiletype scala',
  'BufNewFile,BufReadPre,BufReadPost *.ts,*.tsx setfiletype typescriptreact',
})

aug('language_settings', language_settings_autocmds)

-- hide line numbers in terminals
aug('terminal_numbers', 'TermOpen * setlocal nonumber norelativenumber')

-- automatically neoformat
-- TODO: use prettierd
-- local autoformat_extensions = {'js', 'css', 'html', 'yml', 'yaml'}
-- autoformat_extensions = table.concat(
--   vim.tbl_map(function(ext) return '*.' .. ext end, autoformat_extensions),
--   ','
-- )
-- aug(
--   'autoformatting',
--   'BufWritePre ' .. autoformat_extensions .. ' silent! undojoin | Neoformat'
-- )

aug(
  'packer',
  'User PackerCompileDone '
    .. 'echohl DiffAdd | '
    .. 'echomsg "... packer.nvim loader file compiled!" | '
    .. 'echohl None'
)

-- }}}

-- gui {{{

g.neovide_cursor_animation_length = 0.02
g.neovide_cursor_trail_length = 2
g.neovide_cursor_vfx_mode = "railgun"
g.neovide_cursor_vfx_particle_density = 25
g.neovide_cursor_vfx_particle_curl = 0.005
g.neovide_cursor_animate_in_insert_mode = false
opt.guifont = "PragmataPro Mono:h16"

-- }}}

-- >:O {{{

function map_buf(mode, key, result)
  vim.api.nvim_buf_set_keymap(0, mode, key, result, {noremap = true, silent = true})
end

vim.cmd [[
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
]]

-- }}}

cmd('colorscheme bubblegum-256-dark')
