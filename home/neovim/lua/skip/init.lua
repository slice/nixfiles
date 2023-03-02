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

if vim.env.TERM_PROGRAM == 'iTerm.app' then
  local function set_iterm_profile(profile)
    io.write('\27]1337;SetProfile=' .. profile .. '\a')
  end

  set_iterm_profile('nvim')

  local id = vim.api.nvim_create_augroup('TerminalAugmentation', {})
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = id,
    desc = 'Reverts the iTerm profile to Default before exiting.',
    callback = function()
      set_iterm_profile('Default')
    end,
  })
end

require('skip.options')
require('skip.plugin_options')
require('skip.plugins')
require('skip.lspconfig')
require('skip.completion')
require('skip.mappings')
require('skip.autocmds')

vim.cmd([[colorscheme minicyan]])
