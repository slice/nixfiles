return {
  {
    'tpope/vim-fugitive',
    cmd = 'Git',
    lazy = false,
    keys = {
      { '<Leader>a', '<Cmd>vert G<CR>', desc = 'Git' },
      { '<Leader>q', '<Cmd>.GBrowse!<CR>', desc = '.GBrowse!' },
      { '<Leader>jb', '<Cmd>Git blame<CR>', desc = 'Git blame' },
      { '<Leader>jc', ':G commit -m ""<Left>', desc = ':G commit -m' },
      { '<Leader>jd', '<Cmd>Git difftool<CR>', desc = 'Git difftool' },
      { '<Leader>jp', '<Cmd>G push<CR>', desc = ':G push' },
      {
        '<Leader>jP',
        '<Cmd>G push --force-with-lease<CR>',
        desc = ':G push --force-with-lease',
      },
      { '<Leader>js', '<Cmd>Gdiffsplit<CR>', desc = 'Gdiffsplit' },
      { '<Leader>jv', '<Cmd>Gvdiffsplit<CR>', desc = 'Gvdiffsplit' },
      {
        '<Leader>jV',
        '<Cmd>Gvdiffsplit main:%<CR>',
        desc = 'Gvdiffsplit main:%',
      },
      { '<Leader>jw', '<Cmd>Gwrite<CR>', desc = 'Gwrite' },
    },
  },

  {
    'julienvincent/hunk.nvim',
    cmd = { 'DiffEditor' },
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      require('hunk').setup()
    end,
  },
}
