-- skip's neovim 0.10 config
-- <o_/ <o_/ *quack quack*

if vim.o.shell:find 'bash%-interactive' then
  -- if we're running inside of nix-shell, force $SHELL to fish.
  vim.o.shell = '/run/current-system/sw/bin/fish'
end

require 'skip.options'

-- bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

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
  local lush = require('lush')
  -- vim.loader.reset('skip.skippy')
  lush(require('skip.skippy'))
end

vim.cmd [[colorscheme apparition]]

require('skip.assimilate').create_autocmd()
