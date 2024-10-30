local utils = require('skip.utils')

---@type LazySpec
return {
  {
    'ggandor/leap.nvim',
    dependencies = { 'tpope/vim-repeat' },
    keys = {
      mode = { 'n', 'x', 'o' },
      {
        '<CR>',
        '<Plug>(leap-forward)',
        desc = 'Leap forward',
      },
      {
        '<S-CR>',
        '<Plug>(leap-backward)',
        desc = 'Leap backward',
      },
      {
        '<C-CR>',
        '<Plug>(leap-from-window)',
        desc = 'Leap from window',
      },
      {
        'gs',
        function()
          require 'leap.remote'.action()
        end,
        desc = 'Leap remotely',
        mode = { 'n', 'o' },
      },
      {
        'ga',
        function()
          require 'leap.treesitter'.select()
        end,
        desc = 'Leap (tree-sitter selection)',
      },
      {
        'gA',
        [[V<Cmd>lua require("leap.treesitter").select()<CR>]],
        desc = 'Leap (linewise tree-sitter selection)',
      },
    },
    config = function()
      local leap = require('leap')
      leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

      utils.autocmds('LeapRemote', {
        {
          'User',
          {
            pattern = 'RemoteOperationDone',
            callback = function(event)
              -- don't paste if some special register was in use
              if
                (vim.v.operator == 'y' or vim.v.operator == 'd')
                and event.data.register == '"'
              then
                vim.cmd('normal! p')
              end
            end,
          },
        },
      })
    end,
  },
}
