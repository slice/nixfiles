-- skip's neovim 0.10 config
-- <o_/ <o_/ *quack quack*

if vim.o.shell:find "bash%-interactive" then
  -- If we're running inside of nix-shell, force $SHELL to be fish.
  vim.o.shell = "/run/current-system/sw/bin/fish"
end

require "skip.options"

-- bootstrap lazy
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

require("lazy").setup("skip.plugins", {
  dev = { path = "~/src/prj" },
  change_detection = {
    notify = false,
  },
})

require "skip.mappings"
require "skip.autocmds"

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  desc = "Present some lovely ducks (and startup statistics)",
  callback = function()
    local stats = require("lazy").stats()
    local message = ([[\_o> ♥ ♥ ♥ <o_/ loaded %d/%d plugins in %dms]]):format(
      stats.loaded,
      stats.count,
      stats.startuptime
    )
    vim.api.nvim_echo({
      { message, "DiffAdd" },
    }, true, {})
  end,
})

vim.cmd [[colorscheme skipbones]]

require("skip.assimilate").create_autocmd()
