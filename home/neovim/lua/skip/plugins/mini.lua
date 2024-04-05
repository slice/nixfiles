return {
  {
    "echasnovski/mini.base16",
    priority = 10000,
  },

  {
    "echasnovski/mini.jump",
    opts = {
      delay = {
        idle_stop = 1000 * 8,
      },
    },
    config = function(plugin, opts)
      local jump = require "mini.jump"
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

      vim.keymap.set({ "n", "o", "x" }, ";", jump_forwards, { desc = "Repeat jump (same direction)" })
      vim.keymap.set({ "n", "o", "x" }, ",", jump_backwards, { desc = "Repeat jump (the other direction)" })

      local original_smart_jump = jump.smart_jump
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
    "echasnovski/mini.jump2d",
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
    "echasnovski/mini.indentscope",
    opts = {},
  },

  {
    "echasnovski/mini.surround",
    config = true,
  },

  {
    "echasnovski/mini.trailspace",
    config = true,
  },

  {
    "echasnovski/mini.splitjoin",
    config = true,
  },

  {
    "echasnovski/mini.move",
    config = true,
  },
}
