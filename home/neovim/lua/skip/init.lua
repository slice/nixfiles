-- skip's neovim >= 0.6 config
-- <o_/ *quack quack*

function greet()
  vim.cmd([[echo "\_o> ♥ ♥ ♥ <o_/"]])
end

vim.cmd([[command! Greet :lua greet()<CR>]])
greet()

require('skip.options')
require('skip.plugin_options')
require('skip.plugins')
require('skip.lspconfig')
require('skip.completion')
require('skip.mappings')
require('skip.autocmds')

vim.cmd([[colorscheme bubblegum2]])
