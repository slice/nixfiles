---@type LazySpec
return {
  {
    'echasnovski/mini.animate',
    cond = not HEADLESS,
    opts = function()
      local animate = require('mini.animate')

      return {
        cursor = {
          enable = true,
          timing = animate.gen_timing.linear({ duration = 200, unit = 'total' }),
        },
        scroll = { enable = false },
        resize = { enable = false },
        open = { enable = true },
        close = { enable = true },
      }
    end,
  },
}
