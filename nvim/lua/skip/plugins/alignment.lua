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
    opts = {
      mappings = {
        start = 'gA',
        start_with_preview = 'ga',
      },
    },
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
