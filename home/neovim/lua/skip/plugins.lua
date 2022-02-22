-- vim: set fdm=marker:

require('packer').startup(function()
  use('wbthomason/packer.nvim')

  -- stylua: ignore start
  use('justinmk/vim-dirvish')      -- improved builtin file browser
  use('justinmk/vim-gtfo')         -- gof opens gui file manager
  use('justinmk/vim-sneak')        -- sneak around
  use('junegunn/vim-easy-align')   -- text alignment
  use('tpope/vim-rsi')             -- readline keybindings
  use('tpope/vim-scriptease')      -- utilities for vim scripts
  use('tpope/vim-eunuch')          -- vim sugar for unix shell commands
  use('tpope/vim-commentary')      -- good comment editing
  use('tpope/vim-unimpaired')      -- pairs of handy bracket mappings
  use('tpope/vim-surround')        -- easily edit surrounding characters
  use('tpope/vim-fugitive')        -- delightful git wrapper
  use('tpope/vim-rhubarb')         -- github support for fugitive
  use('tpope/vim-repeat')          -- . works on more stuff
  use('tpope/vim-abolish')         -- better abbrevs, searching, etc.
  use('tpope/vim-afterimage')      -- edit images, pdfs, and plists
  use('mhinz/vim-sayonara')        -- close buffers more intuitively
  use('Konfekt/vim-CtrlXA')        -- superpowers for <C-X> & <C-A>
  use('AndrewRadev/splitjoin.vim') -- splitting and joining stuff
  use('airblade/vim-rooter')       -- cding to project roots
  use('romainl/vim-cool')          -- automatically :nohlsearch
  -- stylua: ignore end

  use({
    'echasnovski/mini.nvim',
  })

  use({
    'cohama/lexima.vim',
    config = function()
      -- don't bind <ESC>, which messes with telescope
      vim.g.lexima_map_escape = ''
    end,
  })

  -- show indentation guides, much like other text editors
  -- use({
  --   'lukas-reineke/indent-blankline.nvim',
  --   config = function()
  --     require('indent_blankline').setup({
  --       -- char = "│",
  --       buftype_exclude = { 'terminal', 'help' },
  --     })
  --   end,
  -- })

  use({
    'slice/nvim-popterm.lua',
    config = function()
      local popterm = require('popterm')
      popterm.config.window_height = 0.8
      vim.cmd([[highlight! link PopTermLabel WildMenu]])
    end,
  })

  -- highlight colors in code (really fast)
  use({
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  })

  local colorschemes = {
    'slice/bubblegum2',
    'junegunn/seoul256.vim',
    'jnurmine/Zenburn',
    'bluz71/vim-moonfly-colors',
    'bluz71/vim-nightfly-guicolors',
    'itchyny/landscape.vim',
  }

  for _, colorscheme in ipairs(colorschemes) do
    use({ colorscheme, opt = true })
  end

  -- language support {{{

  use('LnL7/vim-nix')
  use('rust-lang/rust.vim')
  use('ziglang/zig.vim')
  use('fatih/vim-go')
  use('neovimhaskell/haskell-vim')

  -- }}}

  -- treesitter {{{

  use({
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'typescript',
          'fish',
          'html',
          'json',
          'lua',
          'css',
          'nix',
          'python',
          'rust',
          'tsx',
          'javascript',
          'vim',
          'yaml',
        },
        highlight = { enable = true },
        incremental_selection = { enable = true },
      })

      local ft_to_parser = require('nvim-treesitter.parsers').filetype_to_parsername
      ft_to_parser.typescriptreact = 'tsx'
    end,
  })

  use({
    'lewis6991/spellsitter.nvim',
    config = function()
      require('spellsitter').setup()
    end,
  })

  use({
    'romgrk/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup({
        enable = true,
        throttle = true,
        max_lines = 5,
        patterns = {
          default = { 'class', 'function', 'method' },
        },
      })
    end,
  })

  -- }}}

  -- telescope {{{

  -- extensible multifuzzy finder over pretty much anything
  use({
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } },
    config = function()
      local telescope = require('telescope')

      telescope.setup({
        defaults = {
          winblend = 10,
          color_devicons = false,
          -- immediately close the prompt when pressing <ESC> in insert mode
          mappings = { i = { ['<esc>'] = 'close' } },
        },
      })
    end,
  })

  -- fzf sorter for telescope written in c (speed..)
  use({ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' })

  -- my bespoke project navigator
  use('slice/telescope-trampoline.nvim')

  -- }}}

  -- language server protocol {{{

  use({
    'neovim/nvim-lspconfig',
    requires = { { 'nvim-lua/lsp_extensions.nvim' } },
  })

  -- lsp progress ui
  use({
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup({})
    end,
  })

  -- use neovim itself as a language server in order to inject diagnostics,
  -- code actions, and other lsp-related goodies for languages that do not
  -- have a language server.
  use('jose-elias-alvarez/null-ls.nvim')

  -- }}}

  -- completion {{{

  use({
    'hrsh7th/nvim-cmp',
    requires = {
      {
        -- completion sources
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-calc',
        -- cmp requires a snippet engine to function
        'hrsh7th/cmp-vsnip',
        'hrsh7th/vim-vsnip',
      },
    },
  })

  -- }}}
end)
