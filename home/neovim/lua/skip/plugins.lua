-- vim: set fdm=marker:

require('packer').startup(function()
  use('wbthomason/packer.nvim')

  -- stylua: ignore start
  use('justinmk/vim-dirvish')      -- improved builtin file browser
  use('justinmk/vim-gtfo')         -- gof opens gui file manager
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
    config = function()
      local jump = require('mini.jump')
      jump.setup({
        mappings = {
          repeat_jump = '',
        },
      })

      -- Use more conservative mappings that match closely with vim's existing
      -- motions. I'm not sure why mini.jump decides to remap ; but not ,. It
      -- makes ; repeat the last jump, but in the direction that was last used
      -- (!). Remap them so they work identically (?) to vanilla ; and ,
      -- (always working either forwards or backwards).
      --
      -- stylua: ignore start
      local function jump_forwards() jump.jump(nil) end
      local function jump_backwards()
        local backward = jump.state.backward
        jump.jump(nil, not backward)
        -- The jump we just did updated the state, so preserve the backward
        -- state from before.
        jump.state.backward = backward
      end
      vim.keymap.set('n', ';', jump_forwards, { desc = "Repeat jump (same direction)" })
      vim.keymap.set('x', ';', jump_forwards, { desc = "Repeat jump (same direction)" })
      vim.keymap.set('o', ';', jump_forwards, { desc = "Repeat jump (same direction)" })
      vim.keymap.set('n', ',', jump_backwards, { desc = "Repeat jump (the other direction)" })
      vim.keymap.set('x', ',', jump_backwards, { desc = "Repeat jump (the other direction)" })
      vim.keymap.set('o', ',', jump_backwards, { desc = "Repeat jump (the other direction)" })
      -- stylua: ignore end

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
      require('mini.pairs').setup()
    end,
  })

  use({
    'slice/nvim-popterm.lua',
    config = function()
      local popterm = require('popterm')
      popterm.config.window_height = 0.8
      popterm.config.win_opts = { border = 'none' }
      vim.cmd([[highlight! link PopTermLabel WildMenu]])
    end,
  })

  -- override core UI hooks to make them more user-friendly
  use({
    'stevearc/dressing.nvim',
    config = function()
      require('dressing').setup({
        input = { border = 'single' },
        select = { backend = 'telescope' },
      })
    end,
  })

  -- highlight colors (hex, rgb, etc.) in code (really fast)
  use({
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  })

  for _, colorscheme in ipairs({
    'slice/bubblegum2',
    'junegunn/seoul256.vim',
    'jnurmine/Zenburn',
    'bluz71/vim-moonfly-colors',
    'bluz71/vim-nightfly-guicolors',
    'itchyny/landscape.vim',
    'savq/melange',
    'sainnhe/everforest',
  }) do
    use({ colorscheme })
  end

  -- language "tools" {{{

  use({
    'MrcJkb/haskell-tools.nvim',
    tag = '1.4.2',
    requires = { 'neovim/nvim-lspconfig', 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      local ht = require('haskell-tools')
      local lsp = require('skip.lsp')

      ht.setup({
        hls = {
          on_attach = function(client, bufnr)
            lsp.on_shared_attach(client, bufnr)
            local opts = { buffer = bufnr }
            vim.keymap.set('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
            vim.keymap.set('n', '<leader>hr', ht.repl.toggle, opts)
            vim.keymap.set('n', '<leader>hb', function()
              ht.repl.toggle(vim.api.nvim_buf_get_name(0))
            end, opts)
            vim.keymap.set('n', '<leader>hq', ht.repl.quit, opts)
          end,
        },
      })
    end,
  })

  use({
    'simrat39/rust-tools.nvim',
    config = function()
      local rt = require('rust-tools')
      local lsp = require('skip.lsp')

      rt.setup({
        server = {
          capabilities = lsp.capabilities,
          on_attach = function(client, bufnr)
            lsp.on_shared_attach(client, bufnr)
          end,
        },
        tools = {
          inlay_hints = {
            parameter_hints_prefix = '← ',
            other_hints_prefix = '→ ',
            highlight = 'RustToolsInlayHint',
          },
        },
      })
    end,
  })

  -- }}}

  -- "rudimentary" language support {{{

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
    'romgrk/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup({
        enable = true,
        max_lines = 5,
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

      vim.cmd([[highlight! link TelescopeNormal NormalFloat]])

      -- a custom, compact layout strategy that mimics @norcalli's fuzzy finder
      local layout_strategies = require('telescope.pickers.layout_strategies')
      layout_strategies.compact = function(picker, cols, lines, layout_config)
        local layout = layout_strategies.vertical(picker, cols, lines, layout_config)

        -- make the prompt flush with the status line
        layout.prompt.line = lines + 1
        -- make the results flush with the prompt
        layout.results.line = lines + 3

        return layout
      end

      telescope.setup({
        defaults = {
          winblend = 10,
          color_devicons = false,
          prompt_prefix = '? ',
          selection_caret = '> ',
          border = false,
          preview = false,
          layout_config = { width = 0.5 },
          layout_strategy = 'compact',
          -- immediately close the prompt when pressing <ESC> in insert mode
          mappings = {
            i = {
              ['<esc>'] = 'close',
              ['<c-u>'] = 'results_scrolling_up',
              ['<c-d>'] = 'results_scrolling_down',
            },
          },
        },
        extensions = {
          file_browser = {
            hidden = true,
            disable_devicons = true,
          },
        },
      })

      -- telescope.load_extension('fzf')
      telescope.load_extension('file_browser')
    end,
  })

  -- file browser for telescope
  use({
    'nvim-telescope/telescope-file-browser.nvim',
  })

  -- bespoke project navigator
  use('slice/telescope-trampoline.nvim')

  -- }}}

  -- lsp {{{

  use({
    'neovim/nvim-lspconfig',
    requires = { { 'nvim-lua/lsp_extensions.nvim' } },
    config = function()
      local util = require('lspconfig.util')
      local skip_lsp = require('skip.lsp')

      if util._patched then
        return
      end

      util._patched = true

      local _original_bufname_valid = util.bufname_valid
      function util.bufname_valid(bufname)
        if skip_lsp.bufname_banned(bufname) then
          return false
        end
        return _original_bufname_valid(bufname)
      end
    end,
  })

  -- lsp progress ui
  use({
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup({
        text = { spinner = 'dots_scrolling' },
        timer = { spinner_rate = 50 },
      })
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
  })

  -- }}}
end)
