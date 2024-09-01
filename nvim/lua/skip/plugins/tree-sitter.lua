-- stylua: ignore
local grammars = {
  -- override the parsers that ship with neovim itself, as nvim-treesitter
  -- has newer definitions (important)
  "c",
  "lua",
  "vim",
  "vimdoc",
  "query",

  "asm", "astro", "bash", "cmake", "cpp", "css", "diff", "dockerfile", "dhall",
  "editorconfig", "fish", "git_config", "git_rebase", "gitattributes",
  "gitcommit", "gitignore", "go", "gomod", "gosum", "haskell", "html", "java",
  "javascript", "jsdoc", "json", "json5", "kotlin", "luadoc", "make",
  "markdown", "markdown_inline", "nginx", "nix", "objc", "perl", "php",
  "powershell", "prisma", "proto", "python", "robots", "ruby", "rust", "scss",
  "sql", "swift", "toml", "tsx", "typescript", "typst", "vim", "xml", "yaml",
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
    -- https://github.com/slice/nvim-treesitter-context/commit/55255056d85d6521638c3cf377e6f39cadc58fdb
    -- TODO: remove me when this is fixed upstream (broke 4 hours ago, 2024-09-01)
    "slice/nvim-treesitter-context",
    lazy = false,
    enabled = true,
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
