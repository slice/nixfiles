return {
  {
    "echasnovski/mini.base16",
    priority = 10000,
  },

  {
    "echasnovski/mini.operators",
    config = true,
  },

  {
    "echasnovski/mini.diff",
    config = true,
    opts = {
      view = { style = "sign", signs = { add = "+", change = "~", delete = "-" } },
    },
  },

  {
    "echasnovski/mini.jump",
    opts = {
      delay = {
        idle_stop = 1000 * 8,
      },
    },
    config = function(_, opts)
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
    opts = {
      symbol = "┊",
    },
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

  {
    "echasnovski/mini.pairs",
    opts = {
      -- In which modes mappings from this `config` should be created
      modes = { insert = true, command = false, terminal = false },
    },
    config = function(_, opts)
      local mp = require("mini.pairs")
      mp.setup(opts)

      local function bind_string_token(key)
        vim.keymap.del("i", key)
        vim.keymap.set("i", key, function()
          local neigh_pattern = "[^\\]."
          if key == "'" then
            neigh_pattern = "[^%a\\]."
          end

          local ok, node = pcall(vim.treesitter.get_node, {
            ignore_injections = false,
          })

          local function do_clopen()
            return mp.closeopen(key .. key, neigh_pattern)
          end

          if not ok or not node then
            return do_clopen()
          end

          local within_string_node = node:type():find("^string") ~= nil
          if within_string_node then
            if vim.fn.col(".") == select(2, node:end_()) then
              -- exception: if we are right before the ", then just close it
              return do_clopen()
            end
            return key
          end

          -- local line = vim.api.nvim_get_current_line()
          -- local quotes_currently_in_line = 0
          -- local start = 1 ---@type integer|nil
          --
          -- repeat
          --   start = line:find("%" .. key, start)
          --   if start and line:sub(start - 1, start - 1) ~= "\\" then
          --     quotes_currently_in_line = quotes_currently_in_line + 1
          --   end
          -- until start == nil
          --
          -- vim.notify(tostring(quotes_currently_in_line))
          --
          -- if not within_string_node then
          --   return do_clopen()
          -- end
          --
          -- if quotes_currently_in_line % 2 == 1 then
          --   return key
          -- end

          -- return do_clopen()

          -- somewhat crude; not all tree-sitter grammars will end the string
          -- node at the next line if it's not terminated. they will instead
          -- just end it at the end of the same line
          local string_ends_in_later_line = within_string_node and ({ node:end_() })[1] > (vim.fn.line(".") - 1)
          -- local tree_has_error_anywhere = node:tree():root():has_error()

          if string_ends_in_later_line then
            return key
          end

          return do_clopen()
        end, { expr = true, desc = "bind_string_token for " .. key, replace_keycodes = false })
      end

      bind_string_token('"')
      bind_string_token("'")
      bind_string_token("`")
    end,
  },

  {
    "echasnovski/mini.map",
    -- stylua: ignore
    keys = {
      { "<Leader>mt", function() require("mini.map").toggle() end, desc = "Toggle minimap" },
      { "<Leader>mf", function() require("mini.map").toggle_focus() end, desc = "Toggle minimap focus" },
      { "<Leader>mr", function() require("mini.map").refresh() end, desc = "Refresh minimap" },
      { "<Leader>ms", function() require("mini.map").toggle_side() end, desc = "Switch minimap sides" },
    },
    config = function()
      local map = require("mini.map")

      map.setup {
        symbols = {
          encode = map.gen_encode_symbols.block("3x2"),
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
    "echasnovski/mini.hipatterns",
    config = function()
      local hipatterns = require("mini.hipatterns")

      hipatterns.setup {
        highlighters = {
          fixme = { pattern = "FIXME", group = "MiniHipatternsFixme" },
          hack = { pattern = "HACK", group = "MiniHipatternsHack" },
          todo = { pattern = "TODO", group = "MiniHipatternsTodo" },
          note = { pattern = "NOTE", group = "MiniHipatternsNote" },
          xxx = { pattern = "XXX", group = "MiniHipatternsNote" },
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      }
    end,
  },
}
