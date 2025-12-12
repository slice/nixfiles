-- N.B. using VeryLazy smashes the UI on startup for some reason, (i.e. echo
-- output and :intro gets cleared off)

---@type LazySpec
-- stylua: ignore start
return {
  {
    'justinmk/vim-gtfo',
    keys = { 'gof', 'got' }
    -- TODO map to Ghostty
  },
  {
    'junegunn/vim-easy-align',
    enabled = true,
    keys = {
      { 'ga', '<Plug>(EasyAlign)', remap = true },
      { 'ga', '<Plug>(EasyAlign)', mode = 'x', remap = true },
    },
  },

  'tpope/vim-rsi',         -- readline mappings where they make sense
  'tpope/vim-eunuch',      -- unix helpers (:Remove, :Delete, etc.)
  'tpope/vim-unimpaired',  -- pairs of handy bracket mappings
  'tpope/vim-rhubarb',     -- github integration for fugitive
  'tpope/vim-repeat',      -- let `.` cooperate with plugins
  'tpope/vim-abolish',     -- variants of words
  'mhinz/vim-sayonara',    -- sane buffer/window deletion
  'tommcdo/vim-exchange',  -- swap two bits of text with each other

  -- language support
  'grafana/vim-alloy',
  'alunny/pegjs-vim',
  'isobit/vim-caddyfile',

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
