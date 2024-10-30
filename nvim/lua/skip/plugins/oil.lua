return {
  {
    'stevearc/oil.nvim',
    enabled = false,
    cmd = 'Oil',
    keys = {
      { '<Leader>e', '<Cmd>Oil --float .<CR>', mode = 'n' },
    },
    opts = {
      -- columns = { "permissions", "size", "mtime" },
      columns = {},
      skip_confirm_for_simple_edits = true,
      delete_to_trash = true,
      constrain_cursor = 'name',
      watch_for_changes = true,
      keymaps = {
        ['g?'] = 'actions.show_help',
        ['<CR>'] = 'actions.select',
        -- modified to match vim CTRL-W_ bindings
        ['<C-v>'] = {
          'actions.select',
          opts = { vertical = true },
          desc = 'Open the entry in a vertical split',
        },
        ['<C-s>'] = {
          'actions.select',
          opts = { horizontal = true },
          desc = 'Open the entry in a horizontal split',
        },
        ['<C-t>'] = {
          'actions.select',
          opts = { tab = true },
          desc = 'Open the entry in new tab',
        },
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = 'actions.close',
        ['<C-l>'] = 'actions.refresh',
        ['-'] = 'actions.parent',
        ['_'] = 'actions.open_cwd',
        ['`'] = 'actions.cd',
        ['~'] = {
          'actions.cd',
          opts = { scope = 'tab' },
          desc = ':tcd to the current oil directory',
        },
        ['gs'] = 'actions.change_sort',
        ['gx'] = 'actions.open_external',
        ['g.'] = 'actions.toggle_hidden',
        ['g\\'] = 'actions.toggle_trash',
      },
      view_options = {
        show_hidden = true,
      },
      use_default_keymaps = false, -- needed to override
      keymaps_help = { border = 'single' },
      preview = { border = 'single' },
      progress = { border = 'single' },
      float = {
        max_width = 30,
        max_height = 15,
        border = 'single',
        win_options = { winblend = 30 },
        override = function(conf)
          return vim.tbl_deep_extend('force', conf, {
            anchor = 'NW',
            relative = 'editor',
            row = 0,
            col = 0,
          })
        end,
      },
    },
  },
}
