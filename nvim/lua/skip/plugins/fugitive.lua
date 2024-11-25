return {
  {
    'tpope/vim-fugitive',
    cmd = 'Git',
    lazy = false,
    keys = {
      { '<Leader>a',  '<Cmd>vert G<CR>',       desc = 'Git' },
      { '<Leader>q',  '<Cmd>.GBrowse!<CR>',    desc = '.GBrowse!' },
      { '<Leader>jd', '<Cmd>Git difftool<CR>', desc = 'Git difftool' },
      { '<Leader>jv', '<Cmd>Gvdiffsplit<CR>',  desc = 'Gvdiffsplit' },
      { '<Leader>js', '<Cmd>Gdiffsplit<CR>',   desc = 'Gdiffsplit' },
      { '<Leader>jc', ':G commit -m "',        desc = ':G commit -m "' },
    },
  },
}
