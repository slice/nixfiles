-- skip's neovim 0.10 config
-- <o_/ <o_/ *quack quack*

if vim.o.shell:find('bash%-interactive') then
  -- If we're running inside of nix-shell, force $SHELL to be fish.
  vim.o.shell = '/run/current-system/sw/bin/fish'
end

require('skip.options')
require('skip.plugin_options')
require('skip.mappings')
require('skip.plugins')
require('skip.lspconfig')
require('skip.completion')
require('skip.autocmds')

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyVimStarted',
  desc = 'Present some lovely ducks (and startup statistics)',
  callback = function()
    local stats = require('lazy').stats()
    local message = ([[\_o> ♥ ♥ ♥ <o_/ loaded %d/%d plugins in %dms]]):format(
      stats.loaded,
      stats.count,
      stats.startuptime
    )
    vim.api.nvim_echo({
      { message, 'DiffAdd' },
    }, true, {})
  end,
})

vim.cmd([[colorscheme seoul256]])

require('skip.assimilate')
