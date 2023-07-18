-- skip's neovim >= 0.6 config
-- <o_/ <o_/ *quack quack*

function greet()
  vim.cmd([[echo "\_o> ♥ ♥ ♥ <o_/"]])
end

vim.cmd([[command! Greet :lua greet()<CR>]])
greet()

_G.P = function(object)
  print(vim.inspect(object))
end

if vim.o.shell:find('bash%-interactive') then
  -- If we're running inside of nix-shell, force $SHELL to be fish.
  vim.o.shell = '/run/current-system/sw/bin/fish'
end

require('skip.options')
require('skip.plugin_options')
require('skip.plugins')
require('skip.lspconfig')
require('skip.completion')
require('skip.mappings')
require('skip.autocmds')

vim.opt.background = 'dark'
vim.cmd([[colorscheme zenburn]])

require('skip.assimilate')
