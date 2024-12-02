return {
  {
    'tpope/vim-fugitive',
    cmd = 'Git',
    lazy = false,
    keys = {
      { '<Leader>a', '<Cmd>vert G<CR>', desc = 'Git' },
      { '<Leader>q', '<Cmd>.GBrowse!<CR>', desc = '.GBrowse!' },
      { '<Leader>jd', '<Cmd>Git difftool<CR>', desc = 'Git difftool' },
      { '<Leader>jv', '<Cmd>Gvdiffsplit<CR>', desc = 'Gvdiffsplit' },
      { '<Leader>jw', '<Cmd>Gwrite<CR>', desc = 'Gwrite' },
      { '<Leader>js', '<Cmd>Gdiffsplit<CR>', desc = 'Gdiffsplit' },
      { '<Leader>jc', ':G commit -m ""<Left>', desc = ':G commit -m' },
      { '<Leader>jp', '<Cmd>G push<CR>', desc = ':G push' },
      {
        '<Leader>jP',
        '<Cmd>G push --force-with-lease<CR>',
        desc = ':G push --force-with-lease',
      },
    },
  },
}
