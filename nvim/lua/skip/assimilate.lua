local M = {}

M.augroup_id = vim.api.nvim_create_augroup("SkipTerminalAssimilation", {})

function M.assimilate()
  if vim.env.TERM_PROGRAM == "iTerm.app" then
    local function set_iterm_profile(profile)
      io.write("\27]1337;SetProfile=" .. profile .. "\a")
    end

    set_iterm_profile("nvim")

    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = M.augroup_id,
      desc = "Reverts the iTerm profile to Default before exiting.",
      callback = function()
        set_iterm_profile("Default")
      end,
    })
    return
  end

  local colorscheme_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg

  -- TODO: what terminals does this (OSC 11) work with? is it standard?
  if vim.env.TERM_PROGRAM == "ghostty" then
    local r, g, b
    vim.api.nvim_create_autocmd("TermResponse", {
      once = true,
      group = M.augroup_id,
      callback = function(args)
        local resp = args.data
        r, g, b = resp:match("\027%]11;rgb:(%w+)/(%w+)/(%w+)")
      end,
    })
    io.stdout:write("\027]11;?")

    local hex = string.format("%06x", colorscheme_bg)
    -- set background color via OSC 11
    io.write("\27]11;rgb:" .. hex:gsub("%x%x", "%1/", 2))

    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = M.augroup_id,
      desc = "Reverts terminal colors to default before exiting.",
      callback = function()
        io.write(("\27]11;rgb:%s/%s/%s"):format(r, g, b))
      end,
    })
    return
  end

  if vim.env.KITTY_PID ~= nil then
    local kitty_extensions = { push_colors = "\27]30001\27\\", pop_colors = "\27]30101\27\\" }

    -- kitty_remote(string.format('set-colors background=\\#%06x', background))
    io.write(kitty_extensions.push_colors)
    io.write(string.format("\27]11;#%06x\27\\", colorscheme_bg))
    -- kitty_remote(string.format('set-colors tab_bar_background=\\#%06x', background))

    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = M.augroup_id,
      desc = "Reverts Kitty colors to default before exiting.",
      callback = function()
        -- kitty_remote(string.format('set-colors --reset'))
        io.write(kitty_extensions.pop_colors)
        -- kitty_remote(string.format('set-colors tab_bar_background=none'))
      end,
    })
  end
end

function M.create_autocmd()
  vim.api.nvim_create_autocmd("UIEnter", {
    group = M.augroup_id,
    callback = M.assimilate,
  })
end

return M
