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
  formatting = {
    fields = { 'abbr', 'kind' },
    format = function(entry, vim_item)
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
    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    -- ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    -- ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
  },
  experimental = {
    -- ghost_text = {},
  },
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = { { name = 'buffer' } },
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = 'path' }, { name = 'cmdline' } }),
})
