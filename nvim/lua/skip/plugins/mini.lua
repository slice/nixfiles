local utils = require('skip.utils')

return {
  {
    'echasnovski/mini.base16',
    priority = 10000,
  },

  {
    'echasnovski/mini.operators',
    enabled = false,
    config = true,
  },

  {
    'echasnovski/mini.diff',
    config = true,
    opts = {
      view = {
        style = 'sign',
        signs = { add = '+', change = '~', delete = '-' },
      },
    },
  },

  {
    'echasnovski/mini.jump',
    opts = {
      delay = {
        idle_stop = 1000 * 8,
      },
    },
    config = function(_, opts)
      local jump = require 'mini.jump'
      jump.setup(opts)

      -- Use more conservative mappings that match closely with vim's existing
      -- motions. I'm not sure why mini.jump decides to remap ; but not ,. It
      -- makes ; repeat the last jump, but in the direction that was last used
      -- (!). Remap them so they work identically (?) to vanilla ; and ,.

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

      vim.keymap.set(
        { 'n', 'o', 'x' },
        ';',
        jump_forwards,
        { desc = 'Repeat jump (same direction)' }
      )
      vim.keymap.set(
        { 'n', 'o', 'x' },
        ',',
        jump_backwards,
        { desc = 'Repeat jump (the other direction)' }
      )

      local original_smart_jump = jump.smart_jump
      ---@diagnostic disable-next-line:duplicate-set-field
      jump.smart_jump = function(...)
        -- Smash the jumping state (effectively making "smart jump" no longer
        -- smart), because we always want to enter a new character when pressing
        -- f, F, t, or T.
        --
        -- I'm patching this function because I can avoid getting away with it :]
        jump.state.jumping = false
        original_smart_jump(...)
      end
    end,
  },

  {
    'echasnovski/mini.jump2d',
    enabled = false,
    opts = {
      allowed_lines = {
        blank = false,
        cursor_before = true,
        cursor_at = true,
        cursor_after = true,
        fold = true,
      },
    },
  },

  {
    'echasnovski/mini.indentscope',
    opts = function()
      local indentscope = require('mini.indentscope')

      return {
        symbol = '│',
        draw = {
          delay = 0,
          animation = indentscope.gen_animation.quadratic({
            easing = 'in',
            duration = 15,
          }),
        },
      }
    end,
    init = function()
      utils.autocmds('SkipMiniIndentscope', {
        {
          'FileType',
          {
            pattern = { 'help', 'TelescopePrompt' },
            callback = function()
              vim.b.miniindentscope_disable = true
            end,
            desc = 'Disable mini.indentscope',
          },
        },
        {
          'TermOpen',
          {
            callback = function()
              vim.b.miniindentscope_disable = true
            end,
            desc = 'Disable mini.indentscope',
          },
        },
      })
    end,
  },

  {
    'echasnovski/mini.surround',
    config = true,
  },

  {
    'echasnovski/mini.trailspace',
    config = true,
  },

  {
    'echasnovski/mini.splitjoin',
    config = true,
  },

  {
    'echasnovski/mini.move',
    config = true,
  },

  {
    'echasnovski/mini.map',
    -- stylua: ignore
    keys = {
      { "<Leader>mt", function() require("mini.map").toggle() end,       desc = "Toggle minimap" },
      { "<Leader>mf", function() require("mini.map").toggle_focus() end, desc = "Toggle minimap focus" },
      { "<Leader>mr", function() require("mini.map").refresh() end,      desc = "Refresh minimap" },
      { "<Leader>ms", function() require("mini.map").toggle_side() end,  desc = "Switch minimap sides" },
    },
    config = function()
      local map = require('mini.map')

      map.setup {
        symbols = {
          encode = map.gen_encode_symbols.block('3x2'),
        },
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diff(),
          map.gen_integration.diagnostic(),
        },
        window = {
          show_integration_count = false,
          width = 3,
        },
      }
    end,
  },

  {
    'echasnovski/mini.hipatterns',
    config = function()
      local hipatterns = require('mini.hipatterns')

      hipatterns.setup {
        highlighters = {
          fixme = { pattern = 'FIXME', group = 'MiniHipatternsFixme' },
          hack = { pattern = 'HACK', group = 'MiniHipatternsHack' },
          todo = { pattern = 'TODO', group = 'MiniHipatternsTodo' },
          note = { pattern = 'NOTE', group = 'MiniHipatternsNote' },
          xxx = { pattern = 'XXX', group = 'MiniHipatternsNote' },
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      }
    end,
  },
}
