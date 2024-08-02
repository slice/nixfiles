-- stylua: ignore
local grammars = {
  -- override the parsers that ship with neovim itself, as nvim-treesitter
  -- has newer definitions (important)
  "c", "lua", "vim", "vimdoc", "query",

  "astro", "css", "fish", "go", "haskell", "html", "javascript", "json",
  "markdown", "markdown_inline", "nix", "python", "rust", "swift", "tsx",
  "typescript", "vim", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line:missing-fields
      require("nvim-treesitter.configs").setup {
        ensure_installed = grammars,

        highlight = {
          enable = true,

          ---@diagnostic disable-next-line:unused-local
          disable = function(lang, bufnr)
            return require("skip.huge").bouncer(bufnr)
          end,
        },

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
    enabled = false, -- too slow? :/
    opts = {},
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
}
