vim.g.mapleader = ' '

-- from: https://github.com/wbthomason/dotfiles/blob/5117f6d76c64baa661368e85a25ca463ff858a05/neovim/.config/nvim/lua/config/utils.lua
local function map(modes, lhs, rhs, opts)
  opts = opts or {}
  if opts.noremap == nil then
    opts.noremap = true
  end
  if type(modes) == 'string' then
    modes = { modes }
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

-- pressing <S-Space> in a terminal used to input <Space>, but it doesn't
-- anymore! sometimes i don't release shift before pressing space, so this is
-- useful
map('t', '<S-Space>', '<Space>')

-- jump around windows easier. this is probably breaking something?
map('n', '<C-H>', '<C-W><C-H>')
map('n', '<C-J>', '<C-W><C-J>')
map('n', '<C-K>', '<C-W><C-K>')
map('n', '<C-L>', '<C-W><C-L>')

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

-- diagnostics
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')

-- telescope
map('n', '<leader>o', '<cmd>Telescope find_files<CR>')
map('n', '<leader>i', '<cmd>Telescope oldfiles<CR>')
map('n', '<leader>b', '<cmd>Telescope buffers<CR>')

map('n', '<leader>lp', '<cmd>lua require"telescope".extensions.trampoline.trampoline.project{}<CR>')
map('n', '<leader>lh', '<cmd>Telescope help_tags<CR>')
map('n', '<leader>lt', '<cmd>Telescope builtin<CR>')
map('n', '<leader>lg', '<cmd>Telescope live_grep<CR>')
map('n', '<leader>lb', '<cmd>Telescope file_browser<CR>')
map('n', '<leader>lc', '<cmd>Telescope colorscheme<CR>')
map('n', '<leader>lls', '<cmd>Telescope lsp_workspace_symbols<CR>')
map('n', '<leader>lld', '<cmd>Telescope diagnostics<CR>')
map('n', '<leader>llr', '<cmd>Telescope lsp_references<CR>')

-- vimrc; https://learnvimscriptthehardway.stevelosh.com/chapters/08.html
-- map('n', '<leader>ve', "bufname('%') == '' ? '<cmd>edit $MYVIMRC<CR>' : '<cmd>vsplit $MYVIMRC<CR>'", { expr = true })
map('n', '<leader>ve', '<cmd>Telescope find_files cwd=~/src/prj/nixfiles/home/neovim<CR>')
map('n', '<leader>vs', '<cmd>vsplit | terminal hm-switch<CR>')
-- map('n', '<leader>ve', '<cmd>edit ~/src/prj/nixfiles/home/neovim<CR>')

-- align stuff easily
-- NOTE: need noremap=false because of <Plug>
map('x', 'ga', '<Plug>(EasyAlign)', { noremap = false })
map('n', 'ga', '<Plug>(EasyAlign)', { noremap = false })

-- Q enters ex mode by default, so let's bind it to gq instead
-- (as suggested by :h gq)
map('n', 'Q', 'gq', { noremap = false })
map('v', 'Q', 'gq', { noremap = false })

-- replace :bdelete with sayonara
map('c', 'bd', 'Sayonara!')

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
map('i', '<C-h>', "vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-h>'", { noremap = false, expr = true })
map('i', '<C-l>', "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'", { noremap = false, expr = true })
