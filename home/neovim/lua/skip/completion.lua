local cmp = require('cmp')

vim.cmd([[
  highlight! link CmpItemKindDefault SpecialKey
  highlight! link CmpItemAbbrMatch Function
  highlight! link CmpItemAbbrMatchFuzzy Function
]])

cmp.setup({
  -- completion = {
  --   completeopt = 'menu,menuone,noinsert'
  -- },
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  sources = {
    { name = 'nvim_lua' },
    { name = 'buffer', keyword_length = 2 },
    { name = 'vsnip' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'calc' },
  },
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    -- ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    -- ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
  },
  experimental = {
    ghost_text = {},
  },
})
