---@type LazySpec
return {
  -- TODO: set up tailwindcss nvim-lspconfig _just_ in here
  {
    'luckasRanarison/tailwind-tools.nvim',
    name = 'tailwind-tools',
    cond = not HEADLESS,
    enabled = false,
    build = ':UpdateRemotePlugins',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
  },
}
