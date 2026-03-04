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

require('skip.huge').setup()
require('skip.prefs.file').setup()
require('skip.prefs.commands').setup()
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
    local message = ([[\_o> ♥ ♥ ♥  <o_/ loaded %d/%d plugins in %.2fms]]):format(
      stats.loaded,
      stats.count,
      stats.startuptime
    )

    -- HACK: needed for the message to appear in Ghostty. seems to work on
    -- iTerm2 though?
    vim.defer_fn(function()
      vim.api.nvim_echo({ { message, 'DiffAdd' } }, true, {})
    end, 100)
  end,
})

local function load_lush_theme(mod)
  -- skip.colors.skippy -> skippy
  local segs = vim.split(mod, '.', { plain = true, trimempty = true })
  local name = segs[#segs]

  vim.g.colors_name = name
  require('lush')(require(mod))
end

if not HEADLESS then
  load_lush_theme('skip.colors.biscuit')

  require('skip.tabs')
  require('skip.assimilate').create_autocmd()
  require('skip.peeking').setup()
end
