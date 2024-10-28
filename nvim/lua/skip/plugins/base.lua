-- N.B. using VeryLazy smashes the UI on startup for some reasonbase
-- (i.e. echo output and :intro gets cleared off)

---@type LazySpec
return {
  { "justinmk/vim-gtfo", keys = { "gof", "got" } },
  {
    "junegunn/vim-easy-align",
    enabled = false,
    keys = {
      { "ga", "<Plug>(EasyAlign)", remap = true },
      { "ga", "<Plug>(EasyAlign)", mode = "x",  remap = true },
    },
  },
  "tpope/vim-rsi",
  "tpope/vim-eunuch",
  "tpope/vim-unimpaired",
  "tpope/vim-rhubarb",
  "tpope/vim-repeat",
  "tpope/vim-abolish",
  "mhinz/vim-sayonara",

  'rktjmp/hotpot.nvim',

  {
    "airblade/vim-rooter",
    cmd = "Rooter",
    keys = {
      { "<Leader>r", "<Cmd>Rooter<CR>", desc = "Rooter" },
    },
    init = function()
      vim.g.rooter_patterns = { ".git" }
      vim.g.rooter_manual_only = true
      vim.g.rooter_cd_cmd = "tcd"
    end,
  },

  {
    "airblade/vim-rooter",
    cmd = "Rooter",
    keys = {
      { "<Leader>r", "<Cmd>Rooter<CR>", desc = "Rooter" },
    },
    init = function()
      vim.g.rooter_patterns = { ".git" }
      vim.g.rooter_manual_only = true
      vim.g.rooter_cd_cmd = "tcd"
    end,
  },

  {
    "danobi/prr",
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/vim")
    end,
  },
}
