return {
  {
    "j-hui/fidget.nvim",
    config = function()
      local fidget = require("fidget")

      fidget.setup {
        progress = {
          display = {
            progress_icon = { "line" },
            progress_style = "DiagnosticVirtualTextWarn",
            done_style = "DiagnosticVirtualTextOk",
            icon_style = "Title",
          },
        },
        notification = {
          configs = {
            default = vim.tbl_deep_extend("force", require("fidget.notification").default_config, { icon = "⚠" }),
          },
          override_vim_notify = true,
          view = {
            group_separator = string.rep("-", 70),
            group_separator_hl = "NonText",
          },
          window = {
            border = "double",
            normal_hl = "Normal",
            winblend = 10,
          },
        },
      }
    end,
  },

  {
    "levouh/tint.nvim",
    enabled = false,
    opts = {
      tint = -60,
      saturation = 0.5,
      highlight_ignore_patterns = { "WinSeparator", "StatusLine", "StatusLineNC", "LineNr", "EndOfBuffer" },
    },
  },

  -- overrides vim.ui
  {
    "stevearc/dressing.nvim",
    opts = {
      input = { border = "single" },
      select = { backend = "telescope" },
    },
  },

  {
    "folke/which-key.nvim",
    config = function()
      local window_width = 120
      local column_width = window_width - 3

      local opts = {
        win = {
          width = 0.25,
          col = 1,
          wo = { winblend = 20 },
          padding = { 1, 1, 1, 1 },
        },
        layout = {
          spacing = 0,
          width = { min = column_width, max = column_width },
        },
        icons = { mappings = false },
      }
      local wk = require("which-key")
      wk.setup(opts)

      wk.add({
        { "<Leader>l", group = "second layer" },
        { "<Leader>ll", group = "third layer" },
        { "<Leader>t", group = "terminals" },
        { "<Leader>v", group = "config" },
        { "<Leader>m", group = "minimap" },
        { "<Leader>c", "<cmd>nohlsearch<CR>", desc = "nohlsearch" },
      })
    end,
  },

  {
    "slice/nvim-popterm.lua",
    config = function()
      local popterm = require "popterm"
      popterm.config.window_height = 0.8
      -- popterm.config.win_opts = { border = "none" }
    end,
  },
}
