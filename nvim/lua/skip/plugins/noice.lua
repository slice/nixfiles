---@type LazySpec
return {
  {
    "folke/noice.nvim",
    enabled = false,
    -- event = "VeryLazy",
    -- don't be lazy as this will swallow startup messages
    ---@module "noice"
    ---@type NoiceConfig
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      cmdline = {
        format = {
          cmdline = { title = '', icon = ':' },
          search_down = { title = '', icon = "/" },
          search_up = { title = '', icon = "?" },
          filter = { title = '', icon = "$" },
          lua = { title = '', icon = "=" },
          help = { title = '', icon = "?" },
        }
      },
      -- `vim.notify` route
      notify = {
        view = "mini",
        opts = {
          win_options = { cursorline = false }
        },
      },
      messages = {
        view = "mini",
        view_error = "mini",
        view_warn = "mini",
      },
      views = {
        popup = {
          border = { style = 'single' },
        },
        cmdline_popup = {
          border = { style = 'single' },
        },
        mini = {
          timeout = 3000,
          align = "message-left",
          focusable = true,
          border = { style = 'single' },
          win_options = {
            cursorline = false,
            winblend = 0,
          },
          position = { row = -2 },
          size = {
            width = 'auto',
            height = 'auto',
            max_width = 150,
          },
        },
      },
      routes = {
        {
          view = "mini",
          filter = { event = "msg_showmode" },
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify"
    },
  }
}
