-- skip's neovim 0.10 config
-- <o_/ <o_/ *quack quack*

if vim.o.shell:find 'bash%-interactive' then
  -- if we're running inside of nix-shell, force $SHELL to fish.
  vim.o.shell = '/run/current-system/sw/bin/fish'
end

require 'skip.options'

-- bootstrap lazy
local function ensure_installed(plugin, branch)
  local _, repo = string.match(plugin, '(.+)/(.+)')
  local repo_path = vim.fn.stdpath('data') .. '/lazy/' .. repo
  if not (vim.uv or vim.loop).fs_stat(repo_path) then
    vim.notify('Installing ' .. plugin .. ' ' .. branch)
    local repo_url = 'https://github.com/' .. plugin .. '.git'
    local out = vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      '--branch=' .. branch,
      repo_url,
      repo_path,
    })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { 'Failed to clone ' .. plugin .. ':\n', 'ErrorMsg' },
        { out,                                   'WarningMsg' },
        { '\nPress any key to exit...' },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  return repo_path
end

local lazy_path = ensure_installed('folke/lazy.nvim', 'stable')
local hotpot_path = ensure_installed('rktjmp/hotpot.nvim', 'v0.14.7')
vim.opt.runtimepath:prepend({ hotpot_path, lazy_path })
vim.loader.enable()
require('hotpot')

-- care should be taken so these are loadable sans plugins (or if they error)
require 'skip.mappings'
require 'skip.autocmds'

require('lazy').setup({
  performance = {
    rtp = { paths = { vim.fn.stdpath('config') .. '/.hotpot' } },
  },
  spec = {
    'rktjmp/hotpot.nvim',
    { import = 'skip.plugins' },
    { import = 'skip.plennels' },
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

_G.skippy()

-- vim.cmd [[colorscheme skipbones]]

require('skip.assimilate').create_autocmd()
