return {
  {
    'j-hui/fidget.nvim',
    cond = not HEADLESS,
    config = function()
      local fidget = require('fidget')

      fidget.setup {
        progress = {
          display = {
            progress_icon = { 'line' },
            progress_style = 'DiagnosticVirtualTextWarn',
            done_style = 'DiagnosticVirtualTextOk',
            icon_style = 'Title',
          },
        },
        notification = {
          configs = {
            default = vim.tbl_deep_extend(
              'force',
              require('fidget.notification').default_config,
              { icon = '⚠' }
            ),
          },
          override_vim_notify = true,
          view = {
            group_separator = string.rep('-', 70),
            group_separator_hl = 'NonText',
          },
          window = {
            border = 'double',
            normal_hl = 'Normal',
            winblend = 10,
          },
        },
      }
    end,
  },

  {
    'levouh/tint.nvim',
    enabled = false,
    cond = not HEADLESS,
    lazy = false,
    opts = {
      tint = -80,
      saturation = 0.5,
      highlight_ignore_patterns = {
        'WinSeparator',
        'StatusLine',
        'StatusLineNC',
        'LineNr',
        'EndOfBuffer',
      },
    },
  },

  -- overrides vim.ui
  {
    'stevearc/dressing.nvim',
    cond = not HEADLESS,
    opts = {
      input = { border = 'single' },
      select = { backend = 'telescope' },
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    cond = not HEADLESS,
    keys = {
      { '<Leader>l', group = 'second layer' },
      { '<Leader>ll', group = 'third layer' },
      { '<Leader>t', group = 'terminals' },
      { '<Leader>v', group = 'config' },
      { '<Leader>m', group = 'minimap' },

      {
        '<Leader>?',
        function()
          require 'which-key'.show({ global = true })
        end,
        desc = 'Show keymaps',
      },
      {
        '<Leader>.',
        function()
          require 'which-key'.show({ global = false })
        end,
        desc = 'Show buffer local keymaps',
      },
      {
        '<Leader>c',
        '<Cmd>nohlsearch<CR>',
        desc = ':nohlsearch',
      },
    },
    ---@module "which-key"
    ---@type wk.Config
    opts = {
      preset = 'helix',
      sort = { 'local', 'order', 'alphanum' },
      triggers = { '<auto>', mode = 'nixsotc' },
      win = {
        -- width = 0.5,
        -- col = 1,
        wo = { winblend = 25 },
        border = 'single',
        -- padding = { 1, 1, 1, 1 },
      },
      icons = {
        separator = '',
        mappings = false,
        colors = false,
      },
    },
  },

  {
    'slice/nvim-popterm.lua',
    cond = not HEADLESS,
    config = function()
      local popterm = require 'popterm'
      popterm.config.window_height = 0.8
      -- popterm.config.win_opts = { border = "none" }
    end,
  },
}
