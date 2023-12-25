return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- completion sources
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-cmdline',

      -- cmp requires a snippet engine to function
      -- TODO: use built-in vim.snippet.
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
    },
    config = function()
      local cmp = require('cmp')

      -- TODO: move these out, they need to be applied by default but not override
      -- colorschemes that actually define colors for these
      vim.cmd([[
        highlight! link CmpItemKindDefault SpecialKey
        highlight! link CmpItemAbbrMatch Function
        highlight! link CmpItemAbbrMatchFuzzy Function
      ]])

      cmp.setup({
        -- formatting = {
        --   expandable_indicator = true,
        --   fields = { 'abbr' },
        --   format = function(entry, vim_item)
        --     local max = 40
        --     if vim_item.abbr:len() > max then
        --       vim_item.abbr = vim_item.abbr:sub(0, max) .. '…'
        --     end
        --     -- nuke these, these seem to still affect the window width
        --     vim_item.menu = ''
        --     vim_item.kind = ''
        --     return vim_item
        --   end,
        -- },
        snippet = {
          expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
          end,
        },
        sources = cmp.config.sources(
          -- be aggressive with resolving math expression, because sometimes
          -- the lsp source takes precedence
          { { name = 'calc' } },
          { { name = 'nvim_lsp' }, { name = 'nvim_lsp_signature_help' }, { name = 'vsnip' } },
          { { name = 'nvim_lua' }, { name = 'buffer' } },
          { { name = 'path' } }
        ),
        mapping = {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),
        },
      })
    end,
  },
}
