---@type LazySpec
return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    opts = {
      map_c_w = true,
      check_ts = true,
      enable_check_bracket_line = true,
      fast_wrap = {
        map = '<M-e>',
      }
    },
    init = function()
      -- permit "typing over" commas and semicolons all the time
      for _, punct in pairs { ",", ";" } do
        local npairs = require "nvim-autopairs"
        local Rule = require("nvim-autopairs.rule")

        npairs.add_rules {
          Rule("", punct)
              :with_move(function(opts) return opts.char == punct end)
              :with_pair(function() return false end)
              :with_del(function() return false end)
              :with_cr(function() return false end)
              :use_key(punct)
        }
      end
    end
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = true,
  },

  {
    "metiulekm/nvim-treesitter-endwise",
    event = "InsertEnter",
    opts = {
      endwise = { enable = true },
    },
    config = function(_, opts)
      local npairs = require('nvim-autopairs')

      npairs.add_rules(require('nvim-autopairs.rules.endwise-elixir'))
      npairs.add_rules(require('nvim-autopairs.rules.endwise-lua'))
      npairs.add_rules(require('nvim-autopairs.rules.endwise-ruby'))
      require('nvim-treesitter.configs').setup(opts)
    end
  }
}
