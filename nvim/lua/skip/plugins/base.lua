-- N.B. using VeryLazy smashes the UI on startup for some reason, (i.e. echo
-- output and :intro gets cleared off)

---@type LazySpec
return {
  {
    'justinmk/vim-gtfo',
    keys = { 'gof', 'got' },
    -- TODO map to Ghostty
  },

  'tpope/vim-rsi', -- readline mappings where they make sense
  {
    'tpope/vim-eunuch',
    cmd = {
      'Remove',
      'Unlink',
      'Delete',
      'Copy',
      'Duplicate',
      'Move',
      'Rename',
      'Chmod',
      'Mkdir',
      'Cfind',
      'Lfind',
      'Clocate',
      'Llocate',
      'SudoEdit',
      'SudoWrite',
      'Wall',
      'W',
    },
  },
  {
    'tpope/vim-unimpaired',
    event = 'VeryLazy',
  },
  'tpope/vim-repeat', -- let `.` cooperate with plugins
  {
    'tpope/vim-abolish',
    cmd = { 'Abolish', 'Subvert' },
  },
  'mhinz/vim-sayonara', -- sane buffer/window deletion
  {
    'tommcdo/vim-exchange',
    event = 'VeryLazy',
  },

  -- language support
  {
    'grafana/vim-alloy',
    ft = 'alloy',
  },
  { 'isobit/vim-caddyfile', ft = { 'caddy', 'caddyfile' } },

  {
    'airblade/vim-rooter',
    cmd = 'Rooter',
    keys = {
      { '<Leader>r', '<Cmd>Rooter<CR>', desc = 'Rooter' },
    },
    init = function()
      vim.g.rooter_patterns = { '.git' }
      vim.g.rooter_manual_only = true
      vim.g.rooter_cd_cmd = 'tcd'
    end,
  },

  {
    'danobi/prr',
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. '/vim')
    end,
  },
}
