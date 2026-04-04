---@type LazySpec
return {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      map_c_w = true,
      check_ts = true,
      enable_check_bracket_line = true,
      fast_wrap = {
        map = '<M-e>',
      },
    },
    config = function(_, opts)
      -- permit "typing over" commas and semicolons all the time
      local npairs = require 'nvim-autopairs'
      npairs.setup(opts)
      local Rule = require('nvim-autopairs.rule')

      for _, punct in pairs { ',', ';' } do
        npairs.add_rules {
          Rule('', punct)
            :with_move(function(options)
              return options.char == punct
            end)
            :with_pair(function()
              return false
            end)
            :with_del(function()
              return false
            end)
            :with_cr(function()
              return false
            end)
            :use_key(punct),
        }
      end
    end,
  },

  {
    'windwp/nvim-ts-autotag',
    event = 'InsertEnter',
    config = true,
  },

  {
    'RRethy/nvim-treesitter-endwise',
    -- broken on NVIM 0.12
    enabled = false,
    event = 'InsertEnter',
    commit = '8fe8a95630f4f2c72a87ba1927af649e0bfaa244',
    opts = {},
  },
}
