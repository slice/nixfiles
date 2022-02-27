local b16 = require('mini.base16')

require('mini.base16').setup({
  palette = {
    base00 = '#000000',
    base01 = '#242422',
    base02 = '#484844',
    base03 = '#6c6c66',
    base04 = '#918f88',
    base05 = '#b5b3aa',
    base06 = '#d9d7cc',
    base07 = '#fdfbee',
    base08 = '#ff6c60',
    base09 = '#e9c062',
    base0A = '#e2e29c',
    base0B = '#a8ff60',
    base0C = '#c6c5fe',
    base0D = '#96cbfe',
    base0E = '#f183ef',
    base0F = '#b18a3d',
  },
})

vim.cmd([[highlight! link PmenuThumb PmenuSel]])

vim.g.colors_name = 'mini16'
