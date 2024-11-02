-- stylua: ignore
local grammars = {
  -- override the parsers that ship with neovim itself, as nvim-treesitter
  -- has newer definitions (important)
  "c", "lua", "vim", "vimdoc", "query",

  "asm", "astro", "bash", "cmake", "cpp", "css", "diff", "dockerfile", "dhall",
  "editorconfig", "fish", "git_config", "git_rebase", "gitattributes",
  "gitcommit", "gitignore", "go", "gomod", "gosum", "haskell", "html", "java",
  "javascript", "jsdoc", "json", "json5", "kotlin", "luadoc", "make",
  "markdown", "markdown_inline", "nginx", "nix", "objc", "perl", "php",
  "powershell", "prisma", "proto", "python", "robots", "ruby", "rust", "scss",
  "sql", "swift", "toml", "tsx", "typescript", "typst", "vim", "xml", "yaml",
  "fennel", "racket"
}

---@type LazySpec
return {
  {
    'nvim-treesitter/nvim-treesitter',
    version = false,
    event = 'VeryLazy',
    lazy = vim.fn.argc(-1) == 0, -- load early when file was passed
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    build = ':TSUpdate',
    ---@type TSConfig
    ---@diagnostic disable-next-line:missing-fields
    opts = {
      ensure_installed = grammars,

      highlight = {
        enable = true,

        ---@diagnostic disable-next-line:unused-local
        disable = function(lang, bufnr)
          return require('skip.huge').bouncer(bufnr)
        end,
      },

      indent = { enable = true },

      incremental_selection = {
        keymaps = {
          init_selection = '\\',
          node_incremental = '\\',
          node_decremental = '<bs>',
        },
        enable = true,
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
      vim.treesitter.language.register('typescriptreact', 'tsx')
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    event = 'VeryLazy',
    enabled = true,
    opts = {},
    keys = {
      {
        '[c',
        function()
          require('treesitter-context').go_to_context(vim.v.count1)
        end,
        desc = 'Go to context',
        silent = true,
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',
    enabled = true,
    opts = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          aa = '@parameter.outer',
          ia = '@parameter.inner',
          af = '@function.outer',
          ['if'] = '@function.inner',
          -- FIXME: in `ecma` this is only variable decls and object keyvalue pairs;
          -- plain assignments aren't included
          ['a='] = '@assignment.outer',
          ['i='] = '@assignment.inner',
          ['a;'] = '@statement.outer',
          -- @statement.inner doesn't exist
          ['a?'] = '@conditional.outer',
          ['i?'] = '@conditional.inner',
          ['ac'] = '@class.outer',
          ic = '@class.inner',
          ['a/'] = '@comment.outer',
          ['i/'] = '@comment.inner',
        },
      },
      move = {
        enable = true,
        goto_next_start = {
          [']f'] = '@function.outer',
          [']c'] = '@class.outer',
          [']a'] = '@parameter.inner',
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']C'] = '@class.outer',
          [']A'] = '@parameter.inner',
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[c'] = '@class.outer',
          ['[a'] = '@parameter.inner',
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[C'] = '@class.outer',
          ['[A'] = '@parameter.inner',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<Right>'] = '@parameter.inner',
          ['<Down>'] = '@statement.outer',
        },
        swap_previous = {
          ['<Left>'] = '@parameter.inner',
          ['<Up>'] = '@statement.outer',
        },
      },
      lsp_interop = {
        enable = true,
        border = 'single',
        peek_definition_code = {
          ['<Leader>lpc'] = {
            query = '@class.outer',
            desc = 'Peek class definition',
            silent = true,
          },
          ['<Leader>lpf'] = {
            query = '@function.outer',
            desc = 'Peek function definition',
            silent = true,
          },
        },
      },
    },
    config = function(_, opts)
      ---@diagnostic disable-next-line:missing-fields
      require('nvim-treesitter.configs').setup({ textobjects = opts })
    end,
  },
}
