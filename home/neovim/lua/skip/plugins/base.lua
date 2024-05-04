-- vim: set fdm=marker fdl=1:

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
  "tpope/vim-unimpaired",
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",
  "tpope/vim-repeat",
  "tpope/vim-abolish",
  "tpope/vim-afterimage",
  "romainl/vim-cool",
  "mhinz/vim-sayonara",

  {
    "airblade/vim-rooter",
    cmd = "Rooter",
    keys = {
      { "<Leader>r", "<Cmd>Rooter<CR>", desc = "Rooter" },
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
    config = function()
      local window_width = 120
      local column_width = window_width - 3

      local opts = {
        window = {
          winblend = 20,
          padding = { 1, 1, 1, 1 },
          margin = { 0, 0, 1, 1 },
        },
        layout = {
          spacing = 0,
          width = { min = column_width, max = column_width },
        },
      }
      local wk = require("which-key")
      wk.setup(opts)

      wk.register({
        ["<Leader>"] = {
          l = { name = "+second layer", l = { name = "+third layer" } },
          t = { name = "+terminals" },
          v = { name = " +config" },
        },
      })

      local group = vim.api.nvim_create_augroup("WhichKeyCompact", {})
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "WhichKey",
        callback = function(info)
          local displaying_windows = vim.tbl_filter(function(win)
            return vim.api.nvim_win_get_buf(win) == info.buf and vim.api.nvim_win_is_valid(win)
          end, vim.api.nvim_list_wins())
          if #displaying_windows ~= 1 then
            vim.notify("failed to find whichkey window :(", vim.log.levels.ERROR)
            return
          end
          local displaying_window = displaying_windows[1]
          vim.api.nvim_win_set_config(displaying_window, { width = window_width })
        end,
        group = group,
      })
    end,
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
  { "junegunn/seoul256.vim", lazy = true },
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

  -- treesitter {{{

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line:missing-fields
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          -- override the parsers that ship with neovim itself, as nvim-treesitter
          -- has newer definitions (important)
          "c",
          "lua",
          "vim",
          "vimdoc",
          "query",

          "astro",
          "css",
          "fish",
          "haskell",
          "html",
          "javascript",
          "json",
          "markdown",
          "markdown_inline",
          "nix",
          "python",
          "rust",
          "swift",
          "tsx",
          "typescript",
          "vim",
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
    enabled = false,
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
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        markdown = { "prettier" },
        css = { "prettier" },
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
        desc = "Conform",
      },
    },
    init = function()
      local lsp = require "skip.lsp"
      local conform = require "conform"

      vim.api.nvim_create_autocmd("BufWritePre", {
        desc = "Automatic formatting on buffer write",
        group = lsp.formatting_augroup,
        callback = function(args)
          if lsp.flag_set(lsp.noformat_key) then
            return
          end

          -- don't try to format fugitive buffers
          if vim.api.nvim_buf_get_name(args.buf):find "fugitive://" == 1 then
            return
          end

          if lsp.flag_set "LSP_FORMATTING_ONLY" then
            vim.lsp.buf.format { bufnr = args.buf }
            return
            -- return conform.format { bufnr = args.buf, lsp_fallback = "always", formatters = {} }
          end

          conform.format {
            bufnr = args.buf,
            lsp_fallback = true,
          }
        end,
      })
    end,
  },

  {
    "j-hui/fidget.nvim",
    config = function()
      local fidget = require("fidget")

      fidget.setup {
        progress = {
          display = {
            progress_icon = { "line" },
            progress_style = "DiagnosticVirtualTextWarn",
            done_style = "DiagnosticVirtualTextOk",
            icon_style = "Title",
          },
        },
        notification = {
          configs = {
            default = vim.tbl_deep_extend("force", require("fidget.notification").default_config, { icon = "⚠" }),
          },
          override_vim_notify = true,
          view = {
            group_separator = string.rep("-", 70),
            group_separator_hl = "NonText",
          },
          window = {
            border = "double",
            normal_hl = "Normal",
            winblend = 10,
          },
        },
      }
    end,
  },
}
