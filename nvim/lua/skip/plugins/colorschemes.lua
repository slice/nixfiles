-- mmm yes

return {
  { "lunacookies/vim-apparition", lazy = true },
  { "slice/bubblegum2", lazy = true },
  { "junegunn/seoul256.vim", lazy = true },
  { "bluz71/vim-moonfly-colors", lazy = true },
  { "bluz71/vim-nightfly-guicolors", lazy = true },
  { "itchyny/landscape.vim", lazy = true },
  { "savq/melange", lazy = true },
  { "phha/zenburn.nvim", lazy = true },
  { "sainnhe/everforest", lazy = true },
  {
    "mcchrish/zenbones.nvim",
    lazy = true,
    dependencies = { "rktjmp/lush.nvim" },
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      styles = {
        keywords = { italic = false },
      },
    },
  },
}
