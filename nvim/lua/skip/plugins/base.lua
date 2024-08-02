-- N.B. using VeryLazy smashes the UI on startup for some reason
-- (i.e. echo output and :intro gets cleared off)

return {
  { "justinmk/vim-gtfo", keys = { "gof", "got" } },
  {
    "junegunn/vim-easy-align",
    keys = {
      { "ga", "<Plug>(EasyAlign)", remap = true },
      { "ga", "<Plug>(EasyAlign)", mode = "x", remap = true },
    },
  },
  "tpope/vim-rsi",
  "tpope/vim-eunuch",
  "tpope/vim-unimpaired",
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-repeat",
  "tpope/vim-abolish",
  "mhinz/vim-sayonara",

  {
    "airblade/vim-rooter",
    cmd = "Rooter",
    keys = {
      { "<Leader>r", "<Cmd>Rooter<CR>", desc = "Rooter" },
    },
  },

  {
    "danobi/prr",
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/vim")
    end,
  },
}
