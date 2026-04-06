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
  "powershell", "prisma", "proto", "python", "ruby", "rust", "scss", "sql",
  "swift", "toml", "tsx", "typescript", "typst", "vim", "xml", "yaml",
  "fennel", "racket"
}

---@type LazySpec
return {
  {
    -- (my fork has some haskell highlight fixes)
    'slice/nvim-treesitter',

    -- needs NVIM 0.12
    branch = 'main',

    event = 'VeryLazy',
    lazy = vim.fn.argc(-1) == 0, -- load early when file was passed in argv
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall', 'TSUninstall' },
    build = ':TSUpdate',
    config = function(_)
      local ts = require('nvim-treesitter')
      ts.setup()
      ts.install(grammars)

      local aug =
        vim.api.nvim_create_augroup('nvim-treesitter', { clear = true })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local buf = ev.buf
          local ft = ev.match

          if require('skip.huge').should_bounce(buf) then
            return
          end

          if ft == 'swift' then
            -- too slow
            return
          end

          local lang = vim.treesitter.language.get_lang(ft)

          if lang and vim.treesitter.language.add(lang) then
            -- start neovim's built-in async TS highlighting; this also kills
            -- regex highlighting
            vim.treesitter.start(ev.buf)

            -- (disabled for now because it makes writing haskell annoying)
            -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

            -- i basically always prefer markers; might be nice to enable on
            -- an ad hoc basis though? maybe a pref?
            --
            -- vim.wo.foldmethod = 'expr'
            -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          end
        end,
        group = aug,
      })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    cond = not HEADLESS,
    event = 'VeryLazy',
    enabled = false,
    opts = {
      on_attach = function(bufnr)
        if require 'skip.huge'.was_bounced(bufnr) then
          return false
        end
        -- slows down editing swift files a loooooooot
        return vim.bo[bufnr].filetype ~= 'swift'
      end,
      multiline_threshold = 2,
    },
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
    enabled = false,
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
