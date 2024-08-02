local utils = require("skip.utils")

return {
  {
    "echasnovski/mini.files",
    version = "*",
    -- stylua: ignore
    keys = {
      {"<Leader>d", function() require('mini.files').open() end, desc = "Open mini.files" },
      {"<Leader>e", function() require('mini.files').open(nil, false) end, desc = "Open mini.files to current working directory" },
      {"<Leader>f", function() require('mini.files').open(vim.api.nvim_buf_get_name(0)) end, desc = "Open mini.files to current file" },
    },
    opts = {
      -- hide icons
      content = { prefix = function() end },
      -- trash
      options = {
        permanent_delete = false,
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      vim.cmd [[hi! link MiniFilesTitleFocused Question]]

      utils.autocmds("SkipMiniFiles", {
        {
          "User",
          {
            pattern = "MiniFilesWindowOpen",
            callback = function(args)
              local win_id = args.data.win_id
              vim.wo[win_id].winblend = 20

              local config = vim.api.nvim_win_get_config(win_id)
              config.border = "solid"
              vim.api.nvim_win_set_config(win_id, config)

              -- has to be scheduled for some reason (idk if i want to know why)
              vim.schedule(function()
                vim.wo[win_id].number = true
                vim.wo[win_id].relativenumber = true
              end)
            end,
          },
        },
      })
    end,
  },
}
