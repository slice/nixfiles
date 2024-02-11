-- vim: set fdm=marker:

-- N.B. using VeryLazy smashes the UI on startup for some reason
-- (i.e. echo output and :intro gets cleared off)

return {
  "justinmk/vim-dirvish",
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
  "tpope/vim-commentary",
  "tpope/vim-unimpaired",
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-repeat",
  "tpope/vim-abolish",
  "tpope/vim-afterimage",
  "mhinz/vim-sayonara",
  "Konfekt/vim-CtrlXA",
  "romainl/vim-cool",

  {
    "airblade/vim-rooter",
    cmd = "Rooter",
    keys = {
      { "<Leader>r", "<Cmd>Rooter<CR>" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        untracked = { text = "?" },
      },
    },
  },

  {
    "slice/nvim-popterm.lua",
    config = function()
      local popterm = require "popterm"
      popterm.config.window_height = 0.8
      popterm.config.win_opts = { border = "none" }
    end,
  },

  {
    "folke/which-key.nvim",
    opts = {
      window = {
        winblend = 20,
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "lazy",
          "notify",
        },
      },
    },
    main = "ibl",
  },

  -- override core UI hooks to make them more user-friendly
  {
    "stevearc/dressing.nvim",
    opts = {
      input = { border = "single" },
      select = { backend = "telescope" },
    },
  },

  -- highlight colors (hex, rgb, etc.) in code (really fast)
  {
    "norcalli/nvim-colorizer.lua",
    -- idk why `main` & `config = true` (or `opts = {}`) doesn't work here
    config = function()
      require("colorizer").setup()
    end,
  },

  {
    "levouh/tint.nvim",
    enabled = false,
    opts = {
      tint = -60,
      saturation = 0.5,
      highlight_ignore_patterns = { "WinSeparator", "StatusLine", "StatusLineNC", "LineNr", "EndOfBuffer" },
    },
  },

  -- colorschemes {{{

  { "slice/bubblegum2", lazy = true },
  { "junegunn/seoul256.vim", priority = 1000 },
  { "bluz71/vim-moonfly-colors", lazy = true },
  { "bluz71/vim-nightfly-guicolors", lazy = true },
  { "itchyny/landscape.vim", lazy = true },
  { "savq/melange", lazy = true },
  { "phha/zenburn.nvim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  {
    "mcchrish/zenbones.nvim",
    priority = 1000,
    dependencies = { "rktjmp/lush.nvim" },
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      styles = {
        keywords = { italic = false },
      },
    },
  },

  -- }}}

  -- "rudimentary" language support {{{

  "LnL7/vim-nix",
  "rust-lang/rust.vim",
  "ziglang/zig.vim",
  "fatih/vim-go",
  "neovimhaskell/haskell-vim",
  "projectfluent/fluent.vim",
  "keith/swift.vim",

  -- }}}

  -- treesitter {{{

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          -- override the parsers that ship with neovim itself, as nvim-treesitter
          -- has newer definitions
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",

          "astro",
          "typescript",
          "fish",
          "html",
          "json",
          "css",
          "nix",
          "python",
          "rust",
          "tsx",
          "javascript",
          "vim",
          "markdown",
          "yaml",
        },
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = { init_selection = "\\", node_incremental = "\\", node_decremental = "<bs>" },
        },
      }

      vim.treesitter.language.register("typescriptreact", "tsx")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    config = function()
      require("treesitter-context").setup {}
    end,
    keys = {
      {
        "[g",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        silent = true,
      },
    },
  },

  -- }}}

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        -- typescript = { "prettier" },
        -- typescriptreact = { "prettier" },
        -- javascript = { "prettier" },
        -- javascriptreact = { "prettier" },
        markdown = { "prettier" },
        nix = { "nixfmt" },
      },
      notify_on_error = false,
    },
    keys = {
      {
        "<Leader>lf",
        function()
          require("conform").format { timeout_ms = 3000, lsp_fallback = true }
        end,
        desc = "Format buffer",
      },
    },
    init = function()
      local lsp = require "skip.lsp"

      vim.api.nvim_create_autocmd("BufWritePre", {
        desc = "LSP-powered automatic formatting on buffer write",
        group = lsp.formatting_augroup,
        callback = function(args)
          if lsp.flag_set(lsp.noformat_key) then
            return
          end

          require("conform").format {
            bufnr = args.buf,
            lsp_fallback = true,
          }
        end,
      })
    end,
  },

  {
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        override_vim_notify = true,
      },
    },
  },
}
