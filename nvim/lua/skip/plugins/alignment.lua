---@type LazySpec
return {
  {
    'junegunn/vim-easy-align',
    enabled = false,
    keys = {
      { 'ga', '<Plug>(EasyAlign)', remap = true },
      { 'ga', '<Plug>(EasyAlign)', mode = 'x', remap = true },
    },
  },

  {
    'nvim-mini/mini.align',
    version = '*',
    main = 'mini.align',
    -- if super lazy loaded, then the interactive preview messages get swallowed
    -- up by "-- VISUAL --" etc.
    event = 'VeryLazy',
    opts = function()
      local align = require 'mini.align'

      return {
        mappings = {
          start = 'gA',
          start_with_preview = 'ga',
        },
        modifiers = {
          ['1'] = function(steps, _)
            table.insert(steps.pre_justify, align.gen_step.filter('n == 1'))
          end,
          -- helpful to align SQL table declarations
          ['2'] = function(steps, _)
            table.insert(steps.pre_justify, align.gen_step.filter('n == 2'))
          end,
        },
      }
    end,
    -- keys = {
    --   {
    --     'ga',
    --     mode = { 'n' },
    --     expr = true,
    --     desc = 'Align with preview',
    --   },
    --   {
    --     'ga',
    --     mode = { 'x' },
    --     desc = 'Align with preview',
    --   },
    --   {
    --     'gA',
    --     mode = { 'n' },
    --     expr = true,
    --     desc = 'Align',
    --   },
    --   {
    --     'gA',
    --     mode = { 'x' },
    --     desc = 'Align',
    --   },
    -- },
  },
}
