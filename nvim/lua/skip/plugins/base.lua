-- N.B. using VeryLazy smashes the UI on startup for some reasonbase
-- (i.e. echo output and :intro gets cleared off)

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
  {
    "tpope/vim-fugitive",
    cmd = "Git",
    lazy = false,
    keys = { { "<Leader>a", "<Cmd>vert G<CR>", desc = "Git" } }
  },
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
    init = function()
      vim.g.rooter_patterns = { ".git" }
      vim.g.rooter_manual_only = true
      vim.g.rooter_cd_cmd = "tcd"
    end,
  },

  {
    "ggandor/leap.nvim",
    dependencies = { "tpope/vim-repeat" },
    config = function()
      local leap = require("leap")
      leap.opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }

      vim.keymap.set({ "n", "x", "o" }, "<CR>", "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "<S-CR>", "<Plug>(leap-backward)")
      vim.keymap.set({ "n", "x", "o" }, "<C-CR>", "<Plug>(leap-from-window)")

      vim.keymap.set({ "n", "o" }, "gs", function()
        require("leap.remote").action()
      end)
      vim.api.nvim_create_augroup("LeapRemote", {})
      vim.api.nvim_create_autocmd("User", {
        pattern = "RemoteOperationDone",
        group = "LeapRemote",
        callback = function(event)
          -- Do not paste if some special register was in use.
          if (vim.v.operator == "y" or vim.v.operator == "d") and event.data.register == '"' then
            vim.cmd("normal! p")
          end
        end,
      })

      vim.keymap.set({ "n", "x", "o" }, "ga", function()
        require("leap.treesitter").select()
      end)
      -- linewise
      vim.keymap.set({ "n", "x", "o" }, "gA", 'V<cmd>lua require("leap.treesitter").select()<cr>')
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
