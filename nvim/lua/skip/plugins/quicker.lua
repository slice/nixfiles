return {
  {
    'stevearc/quicker.nvim',
    ft = 'qf',
    keys = {
      {
        '<Leader>a',
        function()
          require 'quicker'.toggle()
        end,
      },
    },
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      follow = { enabled = true },
      -- follow ./lsp.lua
      type_icons = {
        E = '󰋔 ',
        W = ' ',
        I = ' ',
        N = ' ',
        H = ' ',
      },
      on_qf = function(bufnr)
        local ns = vim.api.nvim_create_namespace('quicker_hl')
        -- tweak delimiter (bars separating LineNr and buf filename)
        vim.api.nvim_set_hl(ns, 'Delimiter', {
          fg = '#404c4c',
        })
        local winid = vim.fn.bufwinid(bufnr)
        vim.api.nvim_win_set_hl_ns(winid, ns)
      end,
      keys = {
        {
          '(',
          function()
            require('quicker').collapse()
          end,
          desc = 'Collapse quickfix context',
        },
        {
          ')',
          function()
            require('quicker').expand({
              before = 2,
              after = 2,
              add_to_existing = true,
            })
          end,
          desc = 'Expand quickfix context',
        },
      },
    },
  },
}
