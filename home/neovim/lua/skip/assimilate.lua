local M = {}

local id = vim.api.nvim_create_augroup('SkipTerminalAssimilation', {})

function M.assimilate()
  if vim.env.TERM_PROGRAM == 'iTerm.app' then
    local function set_iterm_profile(profile)
      io.write('\27]1337;SetProfile=' .. profile .. '\a')
    end

    set_iterm_profile('nvim')

    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = id,
      desc = 'Reverts the iTerm profile to Default before exiting.',
      callback = function()
        set_iterm_profile('Default')
      end,
    })
  end

  if vim.env.KITTY_PID ~= nil then
    background = vim.api.nvim_get_hl_by_name('Normal', true).background

    local kitty_extensions = { push_colors = '\27]30001\27\\', pop_colors = '\27]30101\27\\' }
    local function kitty_remote(cmd)
      vim.cmd('silent! !kitty @ ' .. cmd)
    end

    -- kitty_remote(string.format('set-colors background=\\#%06x', background))
    io.write(kitty_extensions.push_colors)
    io.write(string.format('\27]11;#%06x\27\\', background))
    -- kitty_remote(string.format('set-colors tab_bar_background=\\#%06x', background))

    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = id,
      desc = 'Reverts Kitty colors to default before exiting.',
      callback = function()
        -- kitty_remote(string.format('set-colors --reset'))
        io.write(kitty_extensions.pop_colors)
        -- kitty_remote(string.format('set-colors tab_bar_background=none'))
      end,
    })
  end
end

function M.create_autocmd()
  vim.api.nvim_create_autocmd('UIEnter', {
    group = id,
    callback = M.assimilate,
  })
end

return M
