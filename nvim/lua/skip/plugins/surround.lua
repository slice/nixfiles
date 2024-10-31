---@type LazySpec
return {
  {
    'echasnovski/mini.surround',
    opts = function()
      local ts_input = require('mini.surround').gen_spec.input.treesitter
      return {
        respect_selection_type = true,
        custom_surroundings = {
          f = {
            input = ts_input({ outer = '@call.outer', inner = '@call.inner' })
          }
        }
      }
    end,
    init = function()
      -- nop the vanilla `s` so it doesn't timeout to it
      vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')
    end
  },
}
