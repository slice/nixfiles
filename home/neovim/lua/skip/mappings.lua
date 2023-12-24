vim.g.mapleader = ' '

local map = vim.keymap.set

function POPTERM_TOGGLE()
  if IS_POPTERM() then
    -- if we're currently inside a popterm, just hide it
    POPTERM_HIDE()
  else
    POPTERM_NEXT()
  end
end

-- after 6? 7? years of typing <ESC>:w<CR>, it's time for somethin' different
map('n', '<Leader>s', '<cmd>:w<CR>')

-- pressing <S-Space> in a terminal used to input <Space>, but it doesn't
-- anymore! sometimes i don't release shift before pressing space, so this is
-- useful
--
-- update(2023-12-18): doesn't seem to be necessary anymore with CSI u?
map('t', '<S-Space>', '<Space>')

map('!', '<C-j>', '<C-r><C-o>+')

-- jump around windows easier. this is probably breaking something?
map('n', '<C-H>', '<C-W><C-H>')
map('n', '<C-J>', '<C-W><C-J>')
map('n', '<C-K>', '<C-W><C-K>')
map('n', '<C-L>', '<C-W><C-L>')

-- nvim-popterm.lua
map({ 't', 'n' }, '<A-Tab>', '<cmd>lua POPTERM_TOGGLE()<CR>')
-- because neovide doesn't have some mappings yet because of keyboard support
map('n', '<Leader>0', '<cmd> lua POPTERM_TOGGLE()<CR>', { desc = 'Popterm' })

-- cd to vcs root
map('n', '<Leader>r', '<cmd>Rooter<CR>')

-- quickly open :terminals
map('n', '<Leader>te', '<cmd>tabnew +terminal<CR>')
map('n', '<Leader>ts', '<cmd>below split +terminal<CR>')
map('n', '<Leader>tv', '<cmd>vsplit +terminal<CR>')

-- diagnostics
map({ 'v', 'n' }, '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map({ 'v', 'n' }, ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')

-- telescope
map('n', '<Leader>o', '<cmd>Telescope find_files<CR>')
map('n', '<Leader>i', '<cmd>Telescope oldfiles<CR>')
map('n', '<Leader>b', '<cmd>Telescope buffers<CR>')

map(
  'n',
  '<Leader>lp',
  '<cmd>lua require"telescope".extensions.trampoline.trampoline.project{}<CR>',
  { desc = 'Trampoline' }
)
map('n', '<Leader>h', '<cmd>Telescope help_tags<CR>', { desc = 'Telescope help tags' })
map('n', '<Leader>lt', '<cmd>Telescope builtin<CR>', { desc = 'Telescope builtins' })
map('n', '<Leader>g', '<cmd>Telescope live_grep<CR>', { desc = 'Telescope live grep' })
map(
  'n',
  '<Leader>d',
  '<cmd>Telescope file_browser cwd=%:p:h<CR>',
  { desc = 'Telescope file browser (from current file)' }
)
map('n', '<Leader>f', '<cmd>Telescope file_browser<CR>', { desc = 'Telescope file browser' })
map('n', '<Leader>lc', '<cmd>Telescope colorscheme<CR>', { desc = 'Telescope colorscheme' })
map('n', '<Leader>ld', '<cmd>Telescope diagnostics<CR>', { desc = 'Telescope diagnostics' })
map('n', '<Leader>lls', '<cmd>Telescope lsp_workspace_symbols<CR>', { desc = 'LSP workspace symbols' })
map('n', '<Leader>llr', '<cmd>Telescope lsp_references<CR>', { desc = 'LSP references' })

-- vimrc; https://learnvimscriptthehardway.stevelosh.com/chapters/08.html
-- map('n', '<Leader>ve', "bufname('%') == '' ? '<cmd>edit $MYVIMRC<CR>' : '<cmd>vsplit $MYVIMRC<CR>'", { expr = true })
map('n', '<Leader>ve', '<cmd>Telescope find_files cwd=~/src/prj/nixfiles/home/neovim<CR>')
map('n', '<Leader>vn', '<cmd>Telescope find_files cwd=~/src/prj/nixfiles<CR>')
map('n', '<Leader>vs', '<cmd>vsplit | terminal hm-switch<CR>')
-- map('n', '<Leader>ve', '<cmd>edit ~/src/prj/nixfiles/home/neovim<CR>')

-- replace :bdelete with sayonara
map('c', 'bd', 'Sayonara!')

-- if we're using "CSI u" (a specification for accurate key reporting in
-- terminals) or otherwise correctly recognize these key presses, let
-- opt+left/right navigate between words in command-line mode
map('!', '<M-Left>', '<S-Left>')
map('!', '<M-Right>', '<S-Right>')

local command_aliases = {
  -- sometimes i hold down shift for too long ;_;
  W = 'w',
  Wq = 'wq',
  Wqa = 'wqa',
  Q = 'q',
  Qa = 'qa',
  Bd = 'bd',
}

for lhs, rhs in pairs(command_aliases) do
  vim.cmd(string.format('command! -bang %s %s<bang>', lhs, rhs))
end

-- maps so we can use :diffput and :diffget in visual mode
-- (can't use d because it means delete already)
map('v', 'fp', ":'<,'>diffput<CR>")
map('v', 'fo', ":'<,'>diffget<CR>")

-- vsnip
local vsnip_modes = { 'i', 's' }
-- remap for <Plug>, don't replace keycodes since expr (?)
local vsnip_opts = { remap = true, expr = true, replace_keycodes = false }

map(vsnip_modes, '<C-h>', "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : ''", vsnip_opts)
map(vsnip_modes, '<C-l>', "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : ''", vsnip_opts)
