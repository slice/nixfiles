local cmp = require('cmp')

-- TODO: move these out, they need to be applied by default but not override
-- colorschemes that actually define colors for these
vim.cmd([[
  highlight! link CmpItemKindDefault SpecialKey
  highlight! link CmpItemAbbrMatch Function
  highlight! link CmpItemAbbrMatchFuzzy Function
]])

cmp.setup({
  formatting = {
    fields = { 'abbr' },
    format = function(entry, vim_item)
      local max = 40
      if vim_item.abbr:len() > max then
        vim_item.abbr = vim_item.abbr:sub(0, max) .. '…'
      end
      -- nuke these, these seem to still affect the window width
      vim_item.menu = ''
      vim_item.kind = ''
      return vim_item
    end,
  },
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  sources = cmp.config.sources(
    { { name = 'nvim_lsp' }, { name = 'nvim_lsp_signature_help' }, { name = 'vsnip' } },
    { { name = 'nvim_lua' }, { name = 'buffer' } },
    { { name = 'path' }, { name = 'calc' } }
  ),
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  },
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = 'buffer' } },
})
