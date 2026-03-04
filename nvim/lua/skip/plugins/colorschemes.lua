return {
  {
    'lunacookies/vim-apparition',
    cond = not HEADLESS,
    lazy = true,
  },

  {
    'slice/bubblegum2',
    cond = not HEADLESS,
    lazy = true,
  },

  {
    'junegunn/seoul256.vim',
    cond = not HEADLESS,
    lazy = true,
    init = function()
      vim.g.seoul256_background = 236
    end,
  },

  {
    'phha/zenburn.nvim',
    cond = not HEADLESS,
    lazy = true,
  },
  {
    'jnurmine/Zenburn',
    cond = not HEADLESS,
    lazy = true,
    enabled = false,
    init = function()
      vim.g.zenburn_old_Visual = true
      vim.g.zenburn_alternate_Visual = true
      vim.g.zenburn_italic_Comment = true
      vim.g.zenburn_subdued_LineNr = true
    end,
  },
  {
    'mcchrish/zenbones.nvim',
    cond = not HEADLESS,
    lazy = true,
    dependencies = { 'rktjmp/lush.nvim' },
  },
}
