---@type LazySpec
return {
  {
    "nvim-lualine/lualine.nvim",
    enabled = false,
    event = 'VeryLazy',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    ---@module "lualine"
    opts = {
      sections = {
        lualine_a = {
          { 'mode', color = '' }
        },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = {},
        lualine_y = { 'filetype' },
        lualine_z = { 'progress', 'location' }
      },
      options = {
        theme = {
        }
      }
    }
  }
}
