-- https://github.com/microsoft/vscode/blob/3df0be6311211699bbee33b1fda56c19f52a52df/src/vs/editor/common/core/editorColorRegistry.ts#L76-L81

local vsCodeBracketHighlights = {
  '#FFD700', -- gold
  '#DA70D6', -- purple
  '#179FFF', -- blue
}

---@type LazySpec
return {
  {
    'HiPhish/rainbow-delimiters.nvim',
    ---@type rainbow_delimiters.config
    opts = {
      highlight = {
        'RainbowDelimiter1',
        'RainbowDelimiter2',
        'RainbowDelimiter3',
      },
      condition = function(bufnr)
        return vim.b[bufnr].huge_bounced
      end,
    },
    config = function(_, opts)
      require('rainbow-delimiters.setup').setup(opts)

      local group = vim.api.nvim_create_augroup('SkipRainbowDelimiters', {})
      -- setting colorscheme often nukes all highlight groups, so define them
      -- in an autocmd (bad for overriding though)
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = group,
        callback = function()
          for i, color in ipairs(vsCodeBracketHighlights) do
            vim.cmd(('highlight! RainbowDelimiter%d guifg=%s'):format(i, color))
          end
        end,
      })
    end,
  },
}
