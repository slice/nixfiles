-- mmm yes

return {
  -- idk if this even works
  cond = not HEADLESS,

  { 'lunacookies/vim-apparition', lazy = true },
  { 'slice/bubblegum2', lazy = true },
  {
    'junegunn/seoul256.vim',
    lazy = true,
    init = function()
      vim.g.seoul256_background = 236
    end,
  },
  {
    'bluz71/vim-moonfly-colors',
    lazy = true,
    init = function()
      vim.g.moonflyCursorColor = true
      vim.g.moonflyUndercurls = false
      vim.g.moonflyItalics = true
    end,
  },
  {
    'bluz71/vim-nightfly-guicolors',
    lazy = true,
    init = function()
      vim.g.nightflyCursorColor = true
      vim.g.nightflyUndercurls = false
      vim.g.nightflyItalics = false
    end,
  },
  { 'itchyny/landscape.vim', lazy = true },
  { 'savq/melange', lazy = true },
  { 'phha/zenburn.nvim', lazy = true },
  {
    'jnurmine/Zenburn',
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
    'sainnhe/everforest',
    lazy = true,
    init = function()
      vim.g.everforest_ui_contrast = 1
    end,
  },
  {
    'mcchrish/zenbones.nvim',
    lazy = true,
    dependencies = { 'rktjmp/lush.nvim' },
  },
  {
    'folke/tokyonight.nvim',
    lazy = true,
    opts = {
      style = 'moon',
      styles = {
        keywords = { italic = false },
      },
    },
  },
}
