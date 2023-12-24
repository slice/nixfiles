-- vim: set fdm=marker:

-- bootstrap {{{

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- }}}

-- N.B. using VeryLazy smashes the UI on startup for some reason
-- (i.e. echo output and :intro gets cleared off)

require('lazy').setup({
  'justinmk/vim-dirvish',
  { 'justinmk/vim-gtfo', keys = { 'gof', 'got' } },
  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', remap = true },
      { 'ga', '<Plug>(EasyAlign)', mode = 'x', remap = true },
    },
  },
  'tpope/vim-rsi',
  'tpope/vim-eunuch',
  'tpope/vim-commentary',
  'tpope/vim-unimpaired',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-repeat',
  'tpope/vim-abolish',
  'tpope/vim-afterimage',
  'mhinz/vim-sayonara',
  'Konfekt/vim-CtrlXA',
  'airblade/vim-rooter',
  'romainl/vim-cool',

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '-' },
        untracked = { text = '?' },
      },
    },
  },

  {
    'echasnovski/mini.nvim',
    config = function()
      local jump = require('mini.jump')
      jump.setup({
        delay = {
          idle_stop = 1000 * 8,
        },
      })

      -- Use more conservative mappings that match closely with vim's existing
      -- motions. I'm not sure why mini.jump decides to remap ; but not ,. It
      -- makes ; repeat the last jump, but in the direction that was last used
      -- (!). Remap them so they work identically (?) to vanilla ; and ,
      -- (always working either forwards or backwards).

      local function jump_forwards()
        jump.jump(nil)
      end
      local function jump_backwards()
        local backward = jump.state.backward
        jump.jump(nil, not backward)
        -- The jump we just did updated the state, so preserve the backward
        -- state from before.
        jump.state.backward = backward
      end
      vim.keymap.set('n', ';', jump_forwards, { desc = 'Repeat jump (same direction)' })
      vim.keymap.set('x', ';', jump_forwards, { desc = 'Repeat jump (same direction)' })
      vim.keymap.set('o', ';', jump_forwards, { desc = 'Repeat jump (same direction)' })
      vim.keymap.set('n', ',', jump_backwards, { desc = 'Repeat jump (the other direction)' })
      vim.keymap.set('x', ',', jump_backwards, { desc = 'Repeat jump (the other direction)' })
      vim.keymap.set('o', ',', jump_backwards, { desc = 'Repeat jump (the other direction)' })

      local original_smart_jump = jump.smart_jump
      jump.smart_jump = function(...)
        -- Always smash the jumping state (make "smart jump" no longer smart);
        -- we always want to enter a new character to jump to when pressing f,
        -- F, t, or T. I'm "patching" the function because I don't _have_ to
        -- remap these keys like I did with the "repeat jump" ones, and there's
        -- some "make_expr_jump" weirdness that I'd rather avoid touching
        -- if possible (although I sorta am already).
        jump.state.jumping = false
        original_smart_jump(...)
      end

      require('mini.jump2d').setup({
        allowed_lines = {
          blank = false,
          cursor_before = true,
          cursor_at = true,
          cursor_after = true,
          fold = true,
        },
      })

      require('mini.surround').setup()
      require('mini.trailspace').setup()
      require('mini.splitjoin').setup()
      require('mini.move').setup()
    end,
  },

  {
    'slice/nvim-popterm.lua',
    config = function()
      local popterm = require('popterm')
      popterm.config.window_height = 0.8
      popterm.config.win_opts = { border = 'none' }
    end,
  },

  {
    'folke/which-key.nvim',
    opts = {
      window = {
        winblend = 20,
      },
    },
  },

  -- override core UI hooks to make them more user-friendly
  {
    'stevearc/dressing.nvim',
    opts = {
      input = { border = 'single' },
      select = { backend = 'telescope' },
    },
  },

  -- highlight colors (hex, rgb, etc.) in code (really fast)
  {
    'norcalli/nvim-colorizer.lua',
    -- idk why `main` & `config = true` (or `opts = {}`) doesn't work here
    config = function()
      require('colorizer').setup()
    end,
  },

  {
    'levouh/tint.nvim',
    enabled = false,
    opts = {
      tint = -60,
      saturation = 0.5,
      highlight_ignore_patterns = { 'WinSeparator', 'StatusLine', 'StatusLineNC', 'LineNr', 'EndOfBuffer' },
    },
  },

  -- colorschemes {{{

  'slice/bubblegum2',
  'junegunn/seoul256.vim',
  'bluz71/vim-moonfly-colors',
  'bluz71/vim-nightfly-guicolors',
  'itchyny/landscape.vim',
  'savq/melange',
  'phha/zenburn.nvim',
  'sainnhe/everforest',
  {
    'folke/tokyonight.nvim',
    opts = {
      style = 'moon',
      styles = {
        keywords = { italic = false },
      },
    },
  },

  -- }}}

  -- "rudimentary" language support {{{

  'LnL7/vim-nix',
  'rust-lang/rust.vim',
  'ziglang/zig.vim',
  'fatih/vim-go',
  'neovimhaskell/haskell-vim',
  'projectfluent/fluent.vim',
  'keith/swift.vim',

  -- }}}

  -- treesitter {{{

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          -- override the parsers that ship with neovim itself, as nvim-treesitter
          -- has newer definitions
          'c',
          'lua',
          'vim',
          'vimdoc',
          'query',

          'typescript',
          'fish',
          'html',
          'json',
          'css',
          'nix',
          'python',
          'rust',
          'tsx',
          'javascript',
          'vim',
          'markdown',
          'yaml',
        },
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = { init_selection = '\\', node_incremental = '\\', node_decremental = '<bs>' },
        },
      })

      vim.treesitter.language.register('typescriptreact', 'tsx')
    end,
  },

  -- }}}

  -- telescope {{{

  -- extensible multifuzzy finder over pretty much anything
  {
    'nvim-telescope/telescope.nvim',
    -- branch = '0.1.x',
    dev = true,
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Telescope',
    config = function()
      local telescope = require('telescope')
      local fb_actions = require('telescope._extensions.file_browser.actions')
      local action_layout = require('telescope.actions.layout')

      -- a custom, compact layout strategy that mimics @norcalli's fuzzy finder
      local layout_strategies = require('telescope.pickers.layout_strategies')
      layout_strategies.compact = function(picker, cols, lines, layout_config)
        local layout = layout_strategies.vertical(picker, cols, lines, layout_config)

        -- make the prompt flush with the status line
        layout.prompt.line = lines + 1
        -- make the results flush with the prompt
        layout.results.line = lines + 3
        local results_height = 40
        layout.results.height = results_height
        if layout.preview then
          local preview_height = 20
          layout.preview.line = lines - preview_height - results_height + 1
          layout.preview.height = preview_height
        end

        return layout
      end

      layout_strategies.flex_smooshed = function(picker, cols, lines, layout_config)
        local layout = layout_strategies.flex(picker, cols, lines, layout_config)

        layout.results.height = layout.results.height + 1

        return layout
      end

      telescope.setup({
        defaults = {
          prompt_prefix = '? ',
          selection_caret = '> ',
          layout_config = { width = 0.7 },
          layout_strategy = 'flex_smooshed',
          dynamic_preview_title = true,
          results_title = false,
          prompt_title = false,
          mappings = {
            i = {
              -- immediately close the prompt when pressing <ESC> in insert mode
              --
              ['<esc>'] = 'close',
              ['<c-u>'] = false,
              ['<M-p>'] = action_layout.toggle_preview,
            },
          },
        },
        extensions = {
          file_browser = {
            disable_devicons = true,
            mappings = {
              ['i'] = {
                ['<S-cr>'] = fb_actions.create_from_prompt,
                ['<C-o>'] = fb_actions.open,
              },
            },
          },
        },
      })

      -- telescope.load_extension('fzf')
      telescope.load_extension('file_browser')
    end,
  },

  -- file browser for telescope
  'nvim-telescope/telescope-file-browser.nvim',

  { 'slice/telescope-trampoline.nvim', dev = true },

  -- }}}

  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        nix = { 'nixfmt' },
      },
      notify_on_error = false,
    },
  },

  -- lsp {{{

  {
    'neovim/nvim-lspconfig',
    dependencies = { { 'nvim-lua/lsp_extensions.nvim' } },
    config = function()
      local util = require('lspconfig.util')
      local skip_lsp = require('skip.lsp')

      if util._patched then
        return
      end

      util._patched = true

      local original_bufname_valid = util.bufname_valid

      -- some day, this'll break ...
      function util.bufname_valid(bufname)
        if not skip_lsp.attach_allowed(bufname) then
          return false
        end
        return original_bufname_valid(bufname)
      end
    end,
  },

  {
    'pmizio/typescript-tools.nvim',
    ft = { 'typescript', 'typescriptreact' },
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      settings = {
        expose_as_code_action = 'all',
        tsserver_file_preferences = {
          includeInlayParameterNameHints = 'all',
          includeCompletionsForModuleExports = true,
          quotePreference = 'single',
        },
        tsserver_format_options = {
          semicolons = 'remove',
        },
      },
    },
  },

  -- lsp progress ui
  'j-hui/fidget.nvim',

  -- use neovim itself as a language server in order to inject diagnostics,
  -- code actions, and other lsp-related goodies for languages that do not
  -- have a language server.
  -- TODO: replace
  'jose-elias-alvarez/null-ls.nvim',

  -- proper lua editing support for neovim
  {
    'folke/neodev.nvim',
    opts = {
      override = function(root_dir, library)
        -- TODO: use neoconf
        if root_dir:find('nixfiles', 1, true) then
          library.enabled = true
          library.plugins = true
        end
      end,
    },
  },

  -- }}}

  -- completion {{{

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- completion sources
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-cmdline',

      -- cmp requires a snippet engine to function
      'hrsh7th/cmp-vsnip',
      'hrsh7th/vim-vsnip',
      'hrsh7th/vim-vsnip-integ',
    },
  },

  -- }}}
}, {
  dev = {
    path = '~/src/prj',
  },
})
