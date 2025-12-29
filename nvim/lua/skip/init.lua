-- skip's neovim 0.10 config
-- <o_/ <o_/ *quack quack*

_G.HEADLESS = vim.g.vscode ~= nil

if vim.o.shell:find 'bash%-interactive' then
  -- if we're running inside of nix-shell, force $SHELL to fish.
  vim.o.shell = '/run/current-system/sw/bin/fish'
end

-- be sure to set up elementary mappings (and `mapleader`) _before_ lazy is set
-- up)
require 'skip.options'

-- bootstrap lazy.nvim
require 'skip.lazy'

-- care should be taken so these are loadable sans plugins (or if they error)
require 'skip.mappings'
require 'skip.autocmds'

require('lazy').setup({
  spec = {
    { import = 'skip.plugins' },
  },
  change_detection = {
    notify = false,
  },
  dev = { path = vim.fs.abspath('~/src/prj') },
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyVimStarted',
  desc = 'Present some lovely ducks (and startup statistics)',
  callback = function()
    local stats = require('lazy').stats()
    local message = ([[\_o> ♥ ♥ ♥ <o_/ %d/%d plugins in %dms]]):format(
      stats.loaded,
      stats.count,
      stats.startuptime
    )
    vim.api.nvim_echo({ { message, 'DiffAdd' } }, true, {})
  end,
})

function _G.skippy()
  vim.g.colors_name = 'skippy'
  require('lush')(require('skip.skippy'))
end

if not HEADLESS then
  vim.cmd.colorscheme('apparition')
  require('skip.tabs')
  require('skip.assimilate').create_autocmd()
end
