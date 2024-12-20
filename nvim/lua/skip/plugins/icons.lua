---@type LazySpec
return {
  {
    'nvim-tree/nvim-web-devicons',
    cond = not HEADLESS,
    lazy = true,
    opts = function()
      local icons = require('nvim-web-devicons').get_icons()
      return {
        override = vim.tbl_map(function(value)
          value.icon = value.icon .. ' '
          return value
        end, icons),
      }
    end,
    config = true,
  },
}
